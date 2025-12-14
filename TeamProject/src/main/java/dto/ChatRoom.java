package dto;

import java.sql.Timestamp;

public class ChatRoom {
    private long roomId;
    private long itemId;
    private int sellerId;
    private int buyerId;

    
    private String itemTitle;
    private String itemStatus;
    private int itemPrice;
    private String itemThumbnailUrl;

    
    private String sellerName;
    private String buyerName;

    
    private String lastMessage;
    private Timestamp lastMessageAt;

    
    private int unreadCount;

    public long getRoomId() { return roomId; }
    public void setRoomId(long roomId) { this.roomId = roomId; }

    public long getItemId() { return itemId; }
    public void setItemId(long itemId) { this.itemId = itemId; }

    public int getSellerId() { return sellerId; }
    public void setSellerId(int sellerId) { this.sellerId = sellerId; }

    public int getBuyerId() { return buyerId; }
    public void setBuyerId(int buyerId) { this.buyerId = buyerId; }

    public String getItemTitle() { return itemTitle; }
    public void setItemTitle(String itemTitle) { this.itemTitle = itemTitle; }

    public String getItemStatus() { return itemStatus; }
    public void setItemStatus(String itemStatus) { this.itemStatus = itemStatus; }

    public int getItemPrice() { return itemPrice; }
    public void setItemPrice(int itemPrice) { this.itemPrice = itemPrice; }

    public String getItemThumbnailUrl() { return itemThumbnailUrl; }
    public void setItemThumbnailUrl(String itemThumbnailUrl) { this.itemThumbnailUrl = itemThumbnailUrl; }

    public String getSellerName() { return sellerName; }
    public void setSellerName(String sellerName) { this.sellerName = sellerName; }

    public String getBuyerName() { return buyerName; }
    public void setBuyerName(String buyerName) { this.buyerName = buyerName; }

    public String getLastMessage() { return lastMessage; }
    public void setLastMessage(String lastMessage) { this.lastMessage = lastMessage; }

    public Timestamp getLastMessageAt() { return lastMessageAt; }
    public void setLastMessageAt(Timestamp lastMessageAt) { this.lastMessageAt = lastMessageAt; }

    public int getUnreadCount() { return unreadCount; }
    public void setUnreadCount(int unreadCount) { this.unreadCount = unreadCount; }

    public boolean isSeller(int memberNo) { return this.sellerId == memberNo; }
    public int getOtherUserId(int me) { return (me == sellerId) ? buyerId : sellerId; }
    public String getOtherUserName(int me) { return (me == sellerId) ? buyerName : sellerName; }
}
