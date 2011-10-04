package com.nearinfinity.license;

import java.util.Calendar;
import java.util.Date;

public class License {
	private String organization;
	private long users;
	private Date dateIssued;
	private LicenseType type;
	private IssuingKey key;

	public String getOrganization() {
		return organization;
	}

	public void setOrganization(String organization) {
		this.organization = organization;
	}

	public long getUsers() {
		return users;
	}

	public void setUsers(long users) {
		this.users = users;
	}

	public Date getDateIssued() {
		return dateIssued;
	}

	public void setDateIssued(Date dateIssued) {
		this.dateIssued = dateIssued;
	}

	public LicenseType getType() {
		return type;
	}

	public void setType(LicenseType type) {
		this.type = type;
	}

	public IssuingKey getKey() {
		return key;
	}

	public void setKey(IssuingKey key) {
		this.key = key;
	}

	public Date getDateExpires() {
		Calendar cal = Calendar.getInstance();
		cal.setTime(dateIssued);
		cal.add(Calendar.YEAR, 1);
		return cal.getTime();
	}
}