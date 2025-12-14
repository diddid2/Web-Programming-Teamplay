package dto;

/**
 * 즉시구매(택배) 기본 배송지
 * - 구매자가 체크아웃에서 입력한 배송지를 저장해두었다가 다음 구매 시 기본값으로 불러옵니다.
 */
public class BuyerAddress {
    private int buyerId;
    private String recipientName;
    private String phone;
    private String postcode;
    private String address1;
    private String address2;
    private String memo;

    public int getBuyerId() { return buyerId; }
    public void setBuyerId(int buyerId) { this.buyerId = buyerId; }

    public String getRecipientName() { return recipientName; }
    public void setRecipientName(String recipientName) { this.recipientName = recipientName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getPostcode() { return postcode; }
    public void setPostcode(String postcode) { this.postcode = postcode; }

    public String getAddress1() { return address1; }
    public void setAddress1(String address1) { this.address1 = address1; }

    public String getAddress2() { return address2; }
    public void setAddress2(String address2) { this.address2 = address2; }

    public String getMemo() { return memo; }
    public void setMemo(String memo) { this.memo = memo; }
}
