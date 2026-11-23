import 'package:found_it/features/chat/data/models/chat_item_model.dart';
import 'package:found_it/features/chat/data/models/chat_last_message_model.dart';
import 'package:found_it/features/chat/data/models/chat_report_summary_model.dart';
import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';

abstract final class FakeChatData {
  static List<ChatItemModel> get sampleChats => [
        // 1. Sarah Hassan - iPhone 15 Pro (Finder: true, status: chatting) -> Tests Confirm Ownership!
        ChatItemModel(
          matchId: 'm-104-iphone',
          status: 'chatting',
          similarity: 98,
          source: 'auto',
          ownershipVerified: false,
          iAmFinder: true,
          otherUserName: 'Sarah Hassan',
          otherUserAvatar:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
          lastMessageAt: DateTime.now().subtract(const Duration(minutes: 5)),
          unreadCount: 1,
          myReport: ChatReportSummaryModel(
            id: 'r-104',
            refCode: 'RPT-1008',
            type: 'found',
            title: 'Found Blue Titanium iPhone',
            description: 'Found on table at Costa Coffee',
            image:
                'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?auto=format&fit=crop&w=400&q=80',
            categoryNameEn: 'Phones',
            categoryNameAr: 'هواتف',
            cityNameEn: 'Cairo',
            cityNameAr: 'القاهرة',
            areaNameEn: 'New Cairo',
            areaNameAr: 'القاهرة الجديدة',
            itemDate: DateTime.now().subtract(const Duration(days: 1)),
            status: 'matching',
          ),
          otherReport: ChatReportSummaryModel(
            id: 'r-105',
            refCode: 'RPT-1009',
            type: 'lost',
            title: 'Lost iPhone 15 Pro Max',
            description: 'Lost at Point 90 mall cafeteria',
            image:
                'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?auto=format&fit=crop&w=400&q=80',
            categoryNameEn: 'Phones',
            categoryNameAr: 'هواتف',
            cityNameEn: 'Cairo',
            cityNameAr: 'القاهرة',
            areaNameEn: 'New Cairo',
            areaNameAr: 'القاهرة الجديدة',
            itemDate: DateTime.now().subtract(const Duration(days: 1)),
            status: 'matching',
          ),
          lastMessage: ChatLastMessageModel(
            body: 'Yes! The lock screen wallpaper is a golden retriever puppy!',
            hasImage: false,
            isMine: false,
            createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          ),
        ),

        // 2. Mona K. - Wallet (Finder: false, status: chatting) -> Tests Owner view (No Confirm Ownership)
        ChatItemModel(
          matchId: 'm-101-wallet',
          status: 'chatting',
          similarity: 95,
          source: 'auto',
          ownershipVerified: false,
          iAmFinder: false,
          otherUserName: 'Mona K.',
          otherUserAvatar:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          lastMessageAt: DateTime.now().subtract(const Duration(minutes: 12)),
          unreadCount: 2,
          myReport: ChatReportSummaryModel(
            id: 'r-101',
            refCode: 'RPT-1004',
            type: 'lost',
            title: 'Black Leather Wallet',
            description: 'Montblanc wallet containing national ID and cards',
            image:
                'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&w=400&q=80',
            categoryNameEn: 'Wallets',
            categoryNameAr: 'محافظ',
            cityNameEn: 'Cairo',
            cityNameAr: 'القاهرة',
            areaNameEn: 'Maadi',
            areaNameAr: 'المعادي',
            itemDate: DateTime.now().subtract(const Duration(days: 1)),
            status: 'matching',
          ),
          otherReport: ChatReportSummaryModel(
            id: 'r-102',
            refCode: 'RPT-1005',
            type: 'found',
            title: 'Found Men’s Wallet',
            description: 'Found near Grand Mall Maadi stairs',
            image:
                'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&w=400&q=80',
            categoryNameEn: 'Wallets',
            categoryNameAr: 'محافظ',
            cityNameEn: 'Cairo',
            cityNameAr: 'القاهرة',
            areaNameEn: 'Maadi',
            areaNameAr: 'المعادي',
            itemDate: DateTime.now().subtract(const Duration(days: 1)),
            status: 'matching',
          ),
          lastMessage: ChatLastMessageModel(
            body: 'Can you tell me any specific card or ID inside it?',
            hasImage: false,
            isMine: false,
            createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
          ),
        ),

        // 3. Omar S. - AirPods Pro (Verified) -> Tests Handover instructions bar
        ChatItemModel(
          matchId: 'm-102-airpods',
          status: 'verified',
          similarity: 90,
          source: 'auto',
          ownershipVerified: true,
          iAmFinder: true,
          otherUserName: 'Omar S.',
          otherUserAvatar:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          lastMessageAt: DateTime.now().subtract(const Duration(hours: 1)),
          unreadCount: 0,
          myReport: ChatReportSummaryModel(
            id: 'r-201',
            refCode: 'RPT-2001',
            type: 'found',
            title: 'AirPods Pro Case',
            description: 'White case with blue silicone cover found in cafeteria',
            image:
                'https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?auto=format&fit=crop&w=400&q=80',
            categoryNameEn: 'Electronics',
            categoryNameAr: 'إلكترونيات',
            cityNameEn: 'Giza',
            cityNameAr: 'الجيزة',
            areaNameEn: 'Dokki',
            areaNameAr: 'الدقي',
            itemDate: DateTime.now().subtract(const Duration(days: 2)),
            status: 'matching',
          ),
          otherReport: ChatReportSummaryModel(
            id: 'r-202',
            refCode: 'RPT-2002',
            type: 'lost',
            title: 'Lost AirPods Pro',
            description: 'Lost in Dokki near shooting club',
            image:
                'https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?auto=format&fit=crop&w=400&q=80',
            categoryNameEn: 'Electronics',
            categoryNameAr: 'إلكترونيات',
            cityNameEn: 'Giza',
            cityNameAr: 'الجيزة',
            areaNameEn: 'Dokki',
            areaNameAr: 'الدقي',
            itemDate: DateTime.now().subtract(const Duration(days: 2)),
            status: 'matching',
          ),
          lastMessage: ChatLastMessageModel(
            body: 'Ownership verified! Let us arrange handover.',
            hasImage: false,
            isMine: true,
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ),

        // 4. Tarek N. - Sunglasses (Rejected / Closed) -> Tests Closed chat bar
        ChatItemModel(
          matchId: 'm-105-closed',
          status: 'rejected',
          similarity: 78,
          source: 'manual',
          ownershipVerified: false,
          iAmFinder: false,
          otherUserName: 'Tarek N.',
          otherUserAvatar:
              'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=200&q=80',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
          unreadCount: 0,
          myReport: ChatReportSummaryModel(
            id: 'r-401',
            refCode: 'RPT-4001',
            type: 'lost',
            title: 'Ray-Ban Sunglasses',
            description: 'Classic black aviator sunglasses in brown leather case',
            image:
                'https://images.unsplash.com/photo-1511499767150-a48a237f0083?auto=format&fit=crop&w=400&q=80',
            categoryNameEn: 'Accessories',
            categoryNameAr: 'إكسسوارات',
            cityNameEn: 'Cairo',
            cityNameAr: 'القاهرة',
            areaNameEn: 'Zamalek',
            areaNameAr: 'الزمالك',
            itemDate: DateTime.now().subtract(const Duration(days: 4)),
            status: 'active',
          ),
          otherReport: ChatReportSummaryModel(
            id: 'r-402',
            refCode: 'RPT-4002',
            type: 'found',
            title: 'Found Sunglasses Zamalek',
            description: 'Found sunglasses near Gezira club',
            image:
                'https://images.unsplash.com/photo-1511499767150-a48a237f0083?auto=format&fit=crop&w=400&q=80',
            categoryNameEn: 'Accessories',
            categoryNameAr: 'إكسسوارات',
            cityNameEn: 'Cairo',
            cityNameAr: 'القاهرة',
            areaNameEn: 'Zamalek',
            areaNameAr: 'الزمالك',
            itemDate: DateTime.now().subtract(const Duration(days: 4)),
            status: 'active',
          ),
          lastMessage: ChatLastMessageModel(
            body: 'Match was rejected. This chat is closed.',
            hasImage: false,
            isMine: false,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ),
      ];

  static List<ChatMessageEntity> sampleMessages(String matchId) {
    final now = DateTime.now();
    return [
      ChatMessageEntity(
        id: 'msg-1',
        matchId: matchId,
        senderId: 'other',
        body: 'Hello! I saw your post and I think I might have found your item.',
        createdAt: now.subtract(const Duration(hours: 3)),
        isMine: false,
        readAt: now.subtract(const Duration(hours: 2, minutes: 50)),
      ),
      ChatMessageEntity(
        id: 'msg-2',
        matchId: matchId,
        senderId: 'me',
        body: 'Hi! That is amazing news! Can you tell me what color and condition it is in?',
        createdAt: now.subtract(const Duration(hours: 2, minutes: 45)),
        isMine: true,
        readAt: now.subtract(const Duration(hours: 2, minutes: 40)),
      ),
      ChatMessageEntity(
        id: 'msg-3',
        matchId: matchId,
        senderId: 'other',
        body: 'Yes! It is in great condition. I took a quick photo to show you.',
        createdAt: now.subtract(const Duration(hours: 2, minutes: 30)),
        isMine: false,
        imageUrl:
            'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?auto=format&fit=crop&w=600&q=80',
        readAt: now.subtract(const Duration(hours: 2, minutes: 20)),
      ),
      ChatMessageEntity(
        id: 'msg-4',
        matchId: matchId,
        senderId: 'me',
        body: 'Yes! That is 100% mine! The small mark near the corner confirms it.',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 15)),
        isMine: true,
        readAt: now.subtract(const Duration(hours: 1)),
      ),
      ChatMessageEntity(
        id: 'msg-5',
        matchId: matchId,
        senderId: 'other',
        body: 'Great! Whenever you are ready, please confirm ownership so we can view handover instructions.',
        createdAt: now.subtract(const Duration(minutes: 20)),
        isMine: false,
      ),
    ];
  }
}
