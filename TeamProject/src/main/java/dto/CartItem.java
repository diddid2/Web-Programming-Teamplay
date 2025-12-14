package dto;

public class CartItem {
    private long cartId;
    private int memberNo;
    private long itemId;
    private String cartType; 
    private int quantity;

    
    private String title;
    private int price;
    private String thumbnailUrl;
    private String tradeType;
    private String status;
    private String campus;

    public long getCartId() { return cartId; }
    public void setCartId(long cartId) { this.cartId = cartId; }

    public int getMemberNo() { return memberNo; }
    public void setMemberNo(int memberNo) { this.memberNo = memberNo; }

    public long getItemId() { return itemId; }
    public void setItemId(long itemId) { this.itemId = itemId; }

    public String getCartType() { return cartType; }
    public void setCartType(String cartType) { this.cartType = cartType; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }

    public String getThumbnailUrl() { return thumbnailUrl; }
    public void setThumbnailUrl(String thumbnailUrl) { this.thumbnailUrl = thumbnailUrl; }

    public String getTradeType() { return tradeType; }
    public void setTradeType(String tradeType) { this.tradeType = tradeType; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getCampus() { return campus; }
    public void setCampus(String campus) { this.campus = campus; }
}
