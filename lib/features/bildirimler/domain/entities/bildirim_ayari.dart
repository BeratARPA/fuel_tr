class BildirimAyari {
  final bool aktif;
  final bool benzinZam;
  final bool motorinZam;
  final bool lpgZam;
  final bool haberBildirim;
  final bool haftalikOzet;
  final double zamEsigi;
  final double dusmeEsigi;
  final bool dusmeAktif;

  const BildirimAyari({
    this.aktif = true,
    this.benzinZam = true,
    this.motorinZam = true,
    this.lpgZam = true,
    this.haberBildirim = true,
    this.haftalikOzet = true,
    this.zamEsigi = 1.5,
    this.dusmeEsigi = 1.0,
    this.dusmeAktif = true,
  });

  factory BildirimAyari.fromJson(Map<String, dynamic> json) {
    return BildirimAyari(
      aktif: json['aktif'] as bool? ?? true,
      benzinZam: json['benzinZam'] as bool? ?? true,
      motorinZam: json['motorinZam'] as bool? ?? true,
      lpgZam: json['lpgZam'] as bool? ?? true,
      haberBildirim: json['haberBildirim'] as bool? ?? true,
      haftalikOzet: json['haftalikOzet'] as bool? ?? true,
      zamEsigi: (json['zamEsigi'] as num?)?.toDouble() ?? 1.5,
      dusmeEsigi: (json['dusmeEsigi'] as num?)?.toDouble() ?? 1.0,
      dusmeAktif: json['dusmeAktif'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'aktif': aktif,
    'benzinZam': benzinZam,
    'motorinZam': motorinZam,
    'lpgZam': lpgZam,
    'haberBildirim': haberBildirim,
    'haftalikOzet': haftalikOzet,
    'zamEsigi': zamEsigi,
    'dusmeEsigi': dusmeEsigi,
    'dusmeAktif': dusmeAktif,
  };

  BildirimAyari copyWith({
    bool? aktif,
    bool? benzinZam,
    bool? motorinZam,
    bool? lpgZam,
    bool? haberBildirim,
    bool? haftalikOzet,
    double? zamEsigi,
    double? dusmeEsigi,
    bool? dusmeAktif,
  }) {
    return BildirimAyari(
      aktif: aktif ?? this.aktif,
      benzinZam: benzinZam ?? this.benzinZam,
      motorinZam: motorinZam ?? this.motorinZam,
      lpgZam: lpgZam ?? this.lpgZam,
      haberBildirim: haberBildirim ?? this.haberBildirim,
      haftalikOzet: haftalikOzet ?? this.haftalikOzet,
      zamEsigi: zamEsigi ?? this.zamEsigi,
      dusmeEsigi: dusmeEsigi ?? this.dusmeEsigi,
      dusmeAktif: dusmeAktif ?? this.dusmeAktif,
    );
  }
}
