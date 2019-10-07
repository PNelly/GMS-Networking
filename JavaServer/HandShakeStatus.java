
public enum HandShakeStatus {

	AWAITING_ACK(0),
	COMPLETE(1);

	private final int value;

	private HandShakeStatus(int value){
		this.value = value;
	}

	public int getValue(){
		return this.value;
	}
}