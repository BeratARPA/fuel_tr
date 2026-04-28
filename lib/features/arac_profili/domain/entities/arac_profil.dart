class AracProfil {
  final String id;
  final String ad;
  final String yakitTipi; // benzin, motorin, lpg
  final double tuketim; // L/100km
  final double depo; // L
  final String? plaka;
  final String? marka; // ör: Toyota, VW
  final String? model; // ör: Corolla, Golf

  const AracProfil({
    required this.id,
    required this.ad,
    required this.yakitTipi,
    required this.tuketim,
    required this.depo,
    this.plaka,
    this.marka,
    this.model,
  });

  factory AracProfil.fromJson(Map<String, dynamic> json) {
    return AracProfil(
      id: json['id'] as String,
      ad: json['ad'] as String,
      yakitTipi: json['yakitTipi'] as String? ?? 'benzin',
      tuketim: (json['tuketim'] as num).toDouble(),
      depo: (json['depo'] as num).toDouble(),
      plaka: json['plaka'] as String?,
      marka: json['marka'] as String?,
      model: json['model'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ad': ad,
    'yakitTipi': yakitTipi,
    'tuketim': tuketim,
    'depo': depo,
    'plaka': plaka,
    'marka': marka,
    'model': model,
  };
}
