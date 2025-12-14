package dto;

import java.sql.Timestamp;

public class ChatMessage {
    private long msgId;
    private long roomId;
    
    private Integer senderId;
    
    private String messageType;
    private String message;
    private Timestamp createdAt;

    public long getMsgId() { return msgId; }
    public void setMsgId(long msgId) { this.msgId = msgId; }

    public long getRoomId() { return roomId; }
    public void setRoomId(long roomId) { this.roomId = roomId; }

    public Integer getSenderId() { return senderId; }
    public void setSenderId(Integer senderId) { this.senderId = senderId; }

    public String getMessageType() { return messageType; }
    public void setMessageType(String messageType) { this.messageType = messageType; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
