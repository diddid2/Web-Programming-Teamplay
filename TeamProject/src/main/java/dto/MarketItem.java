package dto;

import java.sql.Timestamp;

public class MarketItem {

    private long id;
    private String title;
    private String category;
    private int price;
    private String status;       
    private String campus;
    private String meetingPlace;
    private String meetingTime;
    private String tradeType;    
    private int wishCount;
    private int chatCount;
    private String thumbnailUrl;
    private String description;
    private Integer writerId;    

    
    
    private boolean instantBuy;

    
    private Integer buyerId;
    private Timestamp soldAt;

    public MarketItem() {}

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getCampus() { return campus; }
    public void setCampus(String campus) { this.campus = campus; }

    public String getMeetingPlace() { return meetingPlace; }
    public void setMeetingPlace(String meetingPlace) { this.meetingPlace = meetingPlace; }

    public String getMeetingTime() { return meetingTime; }
    public void setMeetingTime(String meetingTime) { this.meetingTime = meetingTime; }

    public String getTradeType() { return tradeType; }
    public void setTradeType(String tradeType) { this.tradeType = tradeType; }

    public int getWishCount() { return wishCount; }
    public void setWishCount(int wishCount) { this.wishCount = wishCount; }

    public int getChatCount() { return chatCount; }
    public void setChatCount(int chatCount) { this.chatCount = chatCount; }

    public String getThumbnailUrl() { return thumbnailUrl; }
    public void setThumbnailUrl(String thumbnailUrl) { this.thumbnailUrl = thumbnailUrl; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Integer getWriterId() { return writerId; }
    public void setWriterId(Integer writerId) { this.writerId = writerId; }

    public boolean isInstantBuy() { return instantBuy; }
    public void setInstantBuy(boolean instantBuy) { this.instantBuy = instantBuy; }

    public Integer getBuyerId() { return buyerId; }
    public void setBuyerId(Integer buyerId) { this.buyerId = buyerId; }

    public Timestamp getSoldAt() { return soldAt; }
    public void setSoldAt(Timestamp soldAt) { this.soldAt = soldAt; }
}
