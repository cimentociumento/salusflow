class DigitalCertificate {
  final String id;
  final String cnpj;
  final String companyName;
  final String validFrom;
  final String validTo;
  final String issuer;
  final String serialNumber;
  final String publicKey;
  final bool isValid;

  DigitalCertificate({
    required this.id,
    required this.cnpj,
    required this.companyName,
    required this.validFrom,
    required this.validTo,
    required this.issuer,
    required this.serialNumber,
    required this.publicKey,
    required this.isValid,
  });

  factory DigitalCertificate.fromJson(Map<String, dynamic> json) {
    return DigitalCertificate(
      id: json['id'],
      cnpj: json['cnpj'],
      companyName: json['companyName'],
      validFrom: json['validFrom'],
      validTo: json['validTo'],
      issuer: json['issuer'],
      serialNumber: json['serialNumber'],
      publicKey: json['publicKey'],
      isValid: json['isValid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cnpj': cnpj,
      'companyName': companyName,
      'validFrom': validFrom,
      'validTo': validTo,
      'issuer': issuer,
      'serialNumber': serialNumber,
      'publicKey': publicKey,
      'isValid': isValid,
    };
  }

  bool get isExpired {
    final now = DateTime.now();
    final validToDate = DateTime.parse(validTo);
    return now.isAfter(validToDate);
  }
}
