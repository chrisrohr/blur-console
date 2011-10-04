package com.nearinfinity.license;

public class LicensingException extends Exception{

	private static final long serialVersionUID = -7674403449559906355L;

	public LicensingException() {
    }

    public LicensingException(String message) {
        super(message);
    }

    public LicensingException(String message, Throwable cause) {
        super(message, cause);
    }

    public LicensingException(Throwable cause) {
        super(cause);
    }
}
