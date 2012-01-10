package com.nearinfinity.license;

import java.io.File;
import java.io.FileOutputStream;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.StringTokenizer;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.WordUtils;

public class LicensingService {
	public static final String BEGIN = "=== BEGIN LICENSE ===";
	public static final String END = "=== END LICENSE ===";
	public static final String SEP = "\n";

	private CryptoServices cryptoServices;

	public static SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

	public String generateLicense(License lic, IssuingKey issuingKey) throws CryptoServicesException, LicensingException {
		StringBuilder sb = new StringBuilder();
		if (StringUtils.isBlank(lic.getOrganization())) {
			throw new IllegalArgumentException("Organization must not be empty");
		}
		sb.append(lic.getOrganization());
		if (lic.getUsers() == 0) {
			throw new IllegalArgumentException("Number of users must not be zero. -1 = Unlimited.");
		}
		sb.append(SEP).append(lic.getUsers());
		sb.append(SEP).append(lic.getType());
		sb.append(SEP).append(sdf.format(lic.getDateIssued()));
		sb.append(SEP).append(sdf.format(lic.getDateExpires()));
		sb.append(SEP).append("Blur Tools");
		
		if (LicenseType.NODE_YEARLY.equals(lic.getType())) {
			sb.append(SEP).append(lic.getNodes());
		} else if (LicenseType.CLUSTER_YEARLY.equals(lic.getType())) {
			sb.append(SEP).append(lic.getClusters());
		}
		try {
			StringBuilder licString = new StringBuilder(BEGIN).append(SEP);
			byte[] sig = cryptoServices.sign(sb.toString().getBytes(), cryptoServices.getPrivateKey(issuingKey.getPrivateKey()));
			licString.append(sb.toString()).append(SEP).append(WordUtils.wrap(cryptoServices.encodeBase64(sig),	50, null, true));
			return licString.append(SEP).append(END).toString();
		} catch (Exception e) {
			throw new LicensingException(e);
		}
	}
	
	public String generateEmptyGracePeriodFile(IssuingKey issuingKey) throws LicensingException {
		try {
			byte[] sig = cryptoServices.sign("".getBytes(), cryptoServices.getPrivateKey(issuingKey.getPrivateKey()));
			return "\n" + WordUtils.wrap(cryptoServices.encodeBase64(sig), 50, null, true);
		} catch (Exception e) {
			throw new LicensingException(e);
		}
	}

	public License parseLicense(String lic, IssuingKey issuingKey) throws CryptoServicesException, ParseException {
		String licenseBody = StringUtils.substringBefore(StringUtils.substringAfter(lic, BEGIN), END).trim();
		System.out.println(licenseBody);

		License license = new License();
		StringTokenizer st = new StringTokenizer(licenseBody, "\n", false);
		
		license.setOrganization(st.nextToken());
		license.setUsers(Integer.parseInt(st.nextToken()));
		license.setType(LicenseType.valueOf(st.nextToken()));
		license.setDateIssued(sdf.parse(st.nextToken()));
		//Expires Date
		st.nextToken();
		//Description
		String description = st.nextToken();
		String signature = StringUtils.substringAfter(licenseBody, description);
		
		if (LicenseType.NODE_YEARLY.equals(license.getType())) {
			String nodes = st.nextToken();
			license.setNodes(Long.parseLong(nodes));
			signature = StringUtils.substringAfter(licenseBody, nodes);
		} else if (LicenseType.CLUSTER_YEARLY.equals(license.getType())) {
			String clusters = st.nextToken();
			license.setClusters(Integer.parseInt(clusters));
			signature = StringUtils.substringAfter(licenseBody, clusters);
		}
		
		String licenseData = StringUtils.substringBefore(licenseBody, signature);
		
		if (!cryptoServices.verify(licenseData.toString().getBytes(), cryptoServices.decodeBase64(signature), cryptoServices.getPublicKey(issuingKey.getPublicKey()))) {
			throw new SecurityException("Signature does not match");
		}
		
		return license;
	}

	public void setCryptoServices(CryptoServices cryptoServices) {
		this.cryptoServices = cryptoServices;
	}

	public static void main(String[] args) throws Exception {
		if (args.length < 2) {
			System.out.println("Usage: Organization License-type [options]");
			System.exit(1);
		}
		
		LicensingService service = new LicensingService();
		service.setCryptoServices(CryptoServices.getCryptoServices());

		License lic = new License();
		lic.setOrganization(args[0]);
		lic.setUsers(-1);
		lic.setType(LicenseType.valueOf(args[1].toUpperCase()));
		IssuingKey ik = new IssuingKey();
		ik.setDescription("Main");
		ik.setPrivateKey(CryptoServices.getCryptoServices().decodeBase64("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"));
		ik.setPublicKey(CryptoServices.getCryptoServices().decodeBase64("MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAr70Zcg1WlzllR6xuxJEBuaETSbgAHY6IuZ9lqLWPEdj1I8cQdk28NONmsqMj0jHBjDmqby1YYIsj3+kxib6Ow2rxL/r2EXsdzZxXTdVCDzJMX1JqVSKLqXmbYB7gy9xLqxxDYCVZwTmhAQmhU1KN1PA6IzvyNFcPfG11qyzrfwqAJ+8rA4556KtEe9EbWBPh3PEEqcuq7lQAFXrrr32cvluSVgqgTF2eLYaRyyPxgvBTkFSg4OkdzT2gP+ggiL9SBXA9y6yLZZR2ehMxS5GhS+96n95wLF5CIbg4onefQzZ65/VGwaSeWbPM/8RBUcK/jRC99rNcF6phywJCiKMgJ+u9cj1ThuIBm5LhSs2FreCuDNtUkna4ernk0Ndy1vSpTu0+h5IiMbz2cbfDJq++w8Os7J/Pt3XfgON2cHcJyEEbkzsJ71Z8+lebMydzX/al95FyXDrobuUuUfOVNrXWKqFB+BRIHPTVJo2tP9FGjcxhmj5vHQkGEAh/0n9b93cCBN6e//ft9TP/yELT+lSFJIeJOHj8gUvSFT5JfilTjZLHvLweMR9ZVlfseq1NC8EoYWgpa6PQcUh2PzuTBgoCyRCG4/mIqw45ICuLeS/MwGERJqWpxWPKRpSbklWDrFObOrfaPb+bvKzsPvbf0Q1x+Azqr9d4OSm7DunNAtV85aUCAwEAAQ=="));
		lic.setKey(ik);
		
		if (LicenseType.YEARLY.equals(lic.getType())){
			parseArgsForYearly(lic, args);
		} else if (LicenseType.NODE_YEARLY.equals(lic.getType())) {
			parseArgsForNodeYearly(lic, args);
		} else if (LicenseType.CLUSTER_YEARLY.equals(lic.getType())) {
			parseArgsForClusterYearly(lic, args);
		}

		String slic = service.generateLicense(lic, ik);
		File licenseDir = new File("." + File.separator + "licenses" + File.separator + lic.getOrganization().replaceAll("\\s", "_"));
		licenseDir.mkdirs();
		
		IOUtils.write(slic, new FileOutputStream(new File(licenseDir, "blur_tools_" + sdf.format(lic.getDateIssued()) + ".lic")));
		if (LicenseType.NODE_YEARLY.equals(lic.getType())) {
			IOUtils.write(service.generateEmptyGracePeriodFile(ik), new FileOutputStream(new File(licenseDir, "blur_tools_" + sdf.format(lic.getDateIssued()) + ".grc")));
		}
//		System.out.println(slic);
//		service.parseLicense(slic, ik);
	}
	
	private static void parseArgsForYearly(License license, String[] args) throws ParseException {
		if (args.length >= 3) {
			license.setDateIssued(sdf.parse(args[2]));
		} else {
			license.setDateIssued(new Date());
		}
	}
	
	private static void parseArgsForNodeYearly(License license, String[] args) throws ParseException {
		if (args.length < 3) {
			System.out.println("node_yearly license type requires the number of nodes to be passed in.");
			System.exit(1);
		}
		
		license.setNodes(Long.parseLong(args[2]));
		
		if (args.length >= 4) {
			license.setDateIssued(sdf.parse(args[2]));
		} else {
			license.setDateIssued(new Date());
		}
	}
	
	private static void parseArgsForClusterYearly(License license, String[] args) throws ParseException {
		if (args.length < 3) {
			System.out.println("cluster_yearly license type requires the number of clusters to be passed in.");
			System.exit(1);
		}
		
		license.setClusters(Integer.parseInt(args[2]));
		
		if (args.length >= 4) {
			license.setDateIssued(sdf.parse(args[2]));
		} else {
			license.setDateIssued(new Date());
		}
	}
}
