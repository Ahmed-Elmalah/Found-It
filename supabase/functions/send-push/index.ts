// =====================================================================
// FOUND IT - Edge Function "send-push"
//
// What it does:
//   A Database Webhook calls this function every time a row is INSERTED
//   into public.notifications. The function finds that user's phones
//   (public.device_tokens) and sends a push notification to each one
//   with Firebase Cloud Messaging (FCM HTTP v1).
//
// Secrets (Supabase Dashboard -> Edge Functions -> Secrets):
//   FIREBASE_SERVICE_ACCOUNT_B64  the Firebase service account JSON file, base64
//   WEBHOOK_SECRET                random text, also sent by the webhook in the
//                                 "x-webhook-secret" header
//   (SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are provided automatically)
//
// Deploy with "Verify JWT" turned OFF: the webhook proves itself with
// x-webhook-secret instead.
// =====================================================================

import { createClient } from "jsr:@supabase/supabase-js@2";

type NotificationRow = {
  id: string;
  user_id: string;
  type:
    | "potential_match"
    | "new_message"
    | "ownership_verified"
    | "match_rejected"
    | "item_recovered"
    | "claim_passed";
  match_id: string | null;
  report_id: string | null;
  report_title: string | null;
  report_type: "lost" | "found" | null;
  actor_name: string | null;
  message_preview: string | null;
};

type Lang = "en" | "ar";
type PushText = { title: string; body: string };

// Android notification channel. The app (Mohamed) must create a channel
// with this exact id, or Android shows the push in a default channel.
const ANDROID_CHANNEL_ID = "found_it_default";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

// ---------------------------------------------------------------------
// Push texts (Story #5 wording for match + message)
// ---------------------------------------------------------------------
function buildText(n: NotificationRow, lang: Lang): PushText {
  const title = n.report_title ?? "";

  if (lang === "ar") {
    const name = n.actor_name ?? "مستخدم";
    switch (n.type) {
      case "potential_match":
        return {
          title: "تم العثور على تطابق محتمل!",
          body: n.report_type === "found"
            ? "وجدنا بلاغًا قد يطابق الغرض الذي عثرت عليه. اضغط للمحادثة والتحقق من الملكية."
            : "وجدنا بلاغًا قد يطابق غرضك المفقود. اضغط للمحادثة والتحقق من الملكية.",
        };
      case "new_message":
        return { title: `رسالة جديدة من ${name}`, body: "اضغط للعرض." };
      case "ownership_verified":
        return {
          title: "تم تأكيد الملكية",
          body: `${name} أكد أن الغرض يخصك. رتّب موعد التسليم.`,
        };
      case "match_rejected":
        return {
          title: "تم إغلاق المطابقة",
          body: `${name} أغلق المطابقة الخاصة بـ "${title}".`,
        };
      case "item_recovered":
        return {
          title: "تم استرداد الغرض",
          body: `تم تحديد بلاغك "${title}" كمُسترد.`,
        };
      case "claim_passed":
        return {
          title: "تمت الإجابة على أسئلة التحقق",
          body: `${name} أجاب على أسئلة "${title}" بشكل صحيح. يمكنكما المحادثة الآن.`,
        };
    }
  }

  const name = n.actor_name ?? "Someone";
  switch (n.type) {
    case "potential_match":
      return {
        title: "Potential Match Found!",
        body: `We found a report matching your ${n.report_type ?? "lost"} item. ` +
          "Tap to chat and verify ownership.",
      };
    case "new_message":
      return { title: `New message from ${name}`, body: "Tap to view." };
    case "ownership_verified":
      return {
        title: "Ownership verified",
        body: `${name} confirmed the item is yours. Arrange the handover.`,
      };
    case "match_rejected":
      return {
        title: "Match closed",
        body: `${name} closed the match for "${title}".`,
      };
    case "item_recovered":
      return {
        title: "Report recovered",
        body: `Your report "${title}" was marked Recovered.`,
      };
    case "claim_passed":
      return {
        title: "Verification questions answered",
        body: `${name} answered the questions for "${title}" correctly. You can chat now.`,
      };
  }
}

// ---------------------------------------------------------------------
// Google access token (signed JWT -> OAuth token), cached ~1 hour
// ---------------------------------------------------------------------
type ServiceAccount = { project_id: string; client_email: string; private_key: string };

let serviceAccount: ServiceAccount | null = null;
let cachedToken: { value: string; expiresAt: number } | null = null;

function getServiceAccount(): ServiceAccount {
  if (serviceAccount) return serviceAccount;
  const b64 = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_B64");
  if (!b64) throw new Error("Missing secret FIREBASE_SERVICE_ACCOUNT_B64");
  const bytes = Uint8Array.from(atob(b64.trim()), (c) => c.charCodeAt(0));
  serviceAccount = JSON.parse(new TextDecoder().decode(bytes));
  return serviceAccount!;
}

function base64url(bytes: Uint8Array): string {
  let s = "";
  for (const b of bytes) s += String.fromCharCode(b);
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function pemToDer(pem: string): ArrayBuffer {
  const b64 = pem.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  return Uint8Array.from(atob(b64), (c) => c.charCodeAt(0)).buffer;
}

async function getAccessToken(): Promise<string> {
  if (cachedToken && cachedToken.expiresAt > Date.now() + 60_000) {
    return cachedToken.value;
  }

  const sa = getServiceAccount();
  const now = Math.floor(Date.now() / 1000);
  const encode = (o: unknown) => base64url(new TextEncoder().encode(JSON.stringify(o)));

  const unsigned = `${encode({ alg: "RS256", typ: "JWT" })}.${
    encode({
      iss: sa.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    })
  }`;

  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToDer(sa.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = new Uint8Array(
    await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(unsigned)),
  );

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${unsigned}.${base64url(signature)}`,
    }),
  });
  if (!res.ok) {
    throw new Error(`Google token error ${res.status}: ${await res.text()}`);
  }

  const json = await res.json();
  cachedToken = { value: json.access_token, expiresAt: Date.now() + json.expires_in * 1000 };
  return cachedToken.value;
}

// ---------------------------------------------------------------------
// Send to one phone. Returns "sent", "invalid" (token is dead) or "failed".
// ---------------------------------------------------------------------
async function sendToToken(
  accessToken: string,
  token: string,
  n: NotificationRow,
  text: PushText,
): Promise<"sent" | "invalid" | "failed"> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${getServiceAccount().project_id}/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token,
          notification: text,
          // FCM data values must be strings
          data: {
            type: n.type,
            notification_id: n.id,
            match_id: n.match_id ?? "",
            report_id: n.report_id ?? "",
          },
          android: {
            priority: "high",
            notification: { channel_id: ANDROID_CHANNEL_ID, sound: "default" },
          },
        },
      }),
    },
  );

  if (res.ok) return "sent";

  const errorText = await res.text();
  console.error(`FCM error ${res.status} for token ${token.slice(0, 12)}...: ${errorText}`);
  // the app was uninstalled / the token expired -> remove it
  if (res.status === 404 || errorText.includes("UNREGISTERED")) return "invalid";
  return "failed";
}

// ---------------------------------------------------------------------
// Webhook entry point
// ---------------------------------------------------------------------
function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  const secret = Deno.env.get("WEBHOOK_SECRET");
  if (!secret || req.headers.get("x-webhook-secret") !== secret) {
    return json({ error: "unauthorized" }, 401);
  }
  if (req.method !== "POST") {
    return json({ error: "method not allowed" }, 405);
  }

  try {
    const payload = await req.json();
    if (payload?.type !== "INSERT" || payload?.table !== "notifications") {
      return json({ skipped: true });
    }

    const n = payload.record as NotificationRow;

    const { data: tokens, error } = await supabase
      .from("device_tokens")
      .select("token, lang")
      .eq("user_id", n.user_id);
    if (error) throw error;

    if (!tokens || tokens.length === 0) {
      console.log(`notification ${n.id} (${n.type}): user has no device tokens, nothing sent`);
      return json({ sent: 0, reason: "no device tokens" });
    }

    const accessToken = await getAccessToken();
    const results = await Promise.all(
      tokens.map((t) =>
        sendToToken(accessToken, t.token, n, buildText(n, t.lang === "ar" ? "ar" : "en"))
      ),
    );

    const deadTokens = tokens.filter((_, i) => results[i] === "invalid").map((t) => t.token);
    if (deadTokens.length > 0) {
      await supabase.from("device_tokens").delete().in("token", deadTokens);
    }

    const sent = results.filter((r) => r === "sent").length;
    console.log(
      `notification ${n.id} (${n.type}): sent=${sent} removed=${deadTokens.length} ` +
        `failed=${results.length - sent - deadTokens.length}`,
    );
    return json({ sent, removed: deadTokens.length });
  } catch (e) {
    console.error("send-push failed:", e instanceof Error ? e.message : e);
    return json({ error: "internal error" }, 500);
  }
});
