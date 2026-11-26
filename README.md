# EKG Hastalık Tespit Sistemi — Prolog Uzman Sistemi

Yüksek lisans Esnek Programlama dersi kapsamında geliştirilmiş, EKG sinyal parametrelerinden otomatik hastalık teşhisi yapan Prolog tabanlı uzman sistem.

---

## Proje Dosyası

```
Odev1_Prolog/
├── ekg_teshis.pl                       # Tüm sistem: kurallar, hasta verileri, raporlama
└── Türkçe EKG Hastalıkları Rehberi.png # Hastalık kriterleri referans görseli
```

---

## Sistem Mimarisi

`ekg_teshis.pl` altı bölümden oluşur:

| Bölüm | İçerik |
|-------|--------|
| 1 | Sinyal fact formatı ve parametre tanımları |
| 2 | Yardımcı yüklemler (hız, PR, QRS, QTc sınır kontrolleri) |
| 3 | 36 hastalık/durum kuralı |
| 4 | Toplu teşhis ve raporlama yüklemleri |
| 5 | 10 örnek hasta verisi |
| 6 | Hastalık açıklamaları ve interaktif sorgulama |

---

## Sinyal Parametreleri

Her hasta aşağıdaki formatta tanımlanır:

```prolog
sinyal(ID, ritim,         duzenli).      % duzenli | duzensiz | kaotik
sinyal(ID, hiz,           72).           % atım/dk
sinyal(ID, p_dalgasi,     var).          % var | yok | sivri | cift_tepeli | testere_disi | anormal | delta
sinyal(ID, pr_suresi,     160).          % ms  [normal: 120–200]
sinyal(ID, qrs_suresi,    90).           % ms  [normal: < 120]
sinyal(ID, qrs_morfoloji, normal).       % normal | genis | rsR_prime | derin_negatif | bozuk | kaotik
sinyal(ID, qt_suresi,     400).          % ms  (QTc cinsinden)
sinyal(ID, st_segment,    normal).       % normal | elevasyon | depresyon | yaygin_elevasyon
sinyal(ID, t_dalgasi,     normal).       % normal | sivri | negatif | duzlesmis | hiperakut
sinyal(ID, q_dalgasi,     normal).       % normal | patolojik
sinyal(ID, u_dalgasi,     yok).          % yok | var
sinyal(ID, aks,           normal).       % normal | sol_sapma | sag_sapma
sinyal(ID, v1_morfoloji,  normal).       % normal | rSR_prime | derin_S | yuksek_R
sinyal(ID, pr_davranis,   sabit).        % sabit | giderek_uzuyor | dusmus_kompleks | bagimsiz
sinyal(ID, cinsiyet,      erkek).        % erkek | kadin
```

---

## Kural Örnekleri

```prolog
teshis(ID, normal_sinus_ritmi) :-
    sinyal(ID, ritim, duzenli),
    sinyal(ID, p_dalgasi, var),
    sinyal(ID, hiz, H), hiz_normal(H),        % 60–100
    sinyal(ID, pr_suresi, PR), pr_normal(PR),  % 120–200 ms
    sinyal(ID, qrs_suresi, QRS), qrs_normal(QRS),
    sinyal(ID, st_segment, normal),
    sinyal(ID, t_dalgasi, normal).

teshis(ID, atriyal_fibrilasyon) :-
    sinyal(ID, ritim, duzensiz),
    sinyal(ID, p_dalgasi, yok),
    sinyal(ID, qrs_suresi, QRS), qrs_normal(QRS).

teshis(ID, tam_av_blok_3_derece) :-
    sinyal(ID, p_dalgasi, var),
    sinyal(ID, pr_davranis, bagimsiz),
    sinyal(ID, hiz, H), H < 60.

teshis(ID, akut_stemi) :-
    sinyal(ID, st_segment, elevasyon),
    sinyal(ID, t_dalgasi, hiperakut).

teshis(ID, uzun_qt_sendromu) :-
    sinyal(ID, qt_suresi, QTc),
    sinyal(ID, cinsiyet, erkek),
    qtc_uzun_erkek(QTc).   % QTc > 440 ms
```

---

## Kullanım

SWI-Prolog ile dosyayı yükleyin:

```bash
swipl Odev1_Prolog/ekg_teshis.pl
```

### Sorgu Örnekleri

**Tek hasta raporu:**
```prolog
?- teshis_raporu(hasta1).
```

**Açıklamalı rapor:**
```prolog
?- aciklamali_rapor(hasta3).
```

**Tüm hastaları tara:**
```prolog
?- tum_hastalar_raporu.
```

**Belirli bir hastalığı olan hastaları bul:**
```prolog
?- hastaliği_olan_hastalar(atriyal_fibrilasyon).
```

**Acil durumları filtrele (VF, VT, STEMI, Tam AV Blok):**
```prolog
?- acil_durumlar.
```

**Manuel teşhis sorgusu:**
```prolog
?- teshis(hasta2, X).
```

**Yeni hasta verisi ekleyip teşhis:**
```prolog
?- assert(sinyal(yeniHasta, ritim, duzensiz)),
   assert(sinyal(yeniHasta, hiz, 110)),
   assert(sinyal(yeniHasta, p_dalgasi, yok)),
   assert(sinyal(yeniHasta, qrs_suresi, 95)),
   assert(sinyal(yeniHasta, pr_davranis, sabit)),
   assert(sinyal(yeniHasta, cinsiyet, kadin)).

?- teshis(yeniHasta, X).
X = atriyal_fibrilasyon.
```

---

## Çıktı Örnekleri

### hasta1 — Normal Sinüs Ritmi

```
========================================
  EKG TESHIS RAPORU - Hasta: hasta1
========================================
  Toplam 1 teshis bulundu:

  [TESHIS] normal_sinus_ritmi
  [BILGI ] Duzenli ritim, P her QRS oncesinde, Hiz 60-100/dk

========================================
```

### hasta3 — Akut STEMI

```
========================================
  EKG TESHIS RAPORU - Hasta: hasta3
========================================
  Toplam 1 teshis bulundu:

  [TESHIS] akut_stemi
  [BILGI ] Komsu derivasyonlarda ST elevasyonu, genellikle hiperakut T

========================================
```

### hasta4 — Ventriküler Taşikardi

```
========================================
  EKG TESHIS RAPORU - Hasta: hasta4
========================================
  Toplam 1 teshis bulundu:

  [TESHIS] ventrikuler_tasikardi
  [BILGI ] Genis QRS'li hizli ritim, duzenli, Hiz 100-250/dk

========================================
```

### acil_durumlar çıktısı

```
=== ACİL EKG DURUMLARI ===

[!] ventrikuler_fibrilasyon:
    -> Hasta: hasta8

[!] ventrikuler_tasikardi:
    -> Hasta: hasta4

[!] akut_stemi:
    -> Hasta: hasta3
```

---

## Dahili Örnek Hastalar

| Hasta | Teşhis |
|-------|--------|
| hasta1 | Normal sinüs ritmi |
| hasta2 | Atriyal fibrilasyon |
| hasta3 | Akut STEMI |
| hasta4 | Ventriküler taşikardi |
| hasta5 | Sinüs bradikardisi |
| hasta6 | Sağ dal bloğu (RBBB) |
| hasta7 | Hipokalemi |
| hasta8 | Ventriküler fibrilasyon |
| hasta9 | WPW / Preeksitasyon |
| hasta10 | Perikardit |

---

## Desteklenen 36 Hastalık / Durum

| Kategori | Durumlar |
|----------|----------|
| Normal & Sinüs | Normal sinüs ritmi, Sinüs bradikardisi, Sinüs taşikardisi |
| Atriyal | Atriyal fibrilasyon, Atriyal flutter, SVT |
| Ventriküler | Ventriküler taşikardi, Ventriküler fibrilasyon, PAC, PVC |
| AV Bloklar | 1. Derece, Mobitz I, Mobitz II, 3. Derece (Tam) AV Blok |
| Dal Blokları | RBBB, LBBB, Sol anterior fasiküler blok, WPW |
| QT Bozuklukları | Uzun QT, Kısa QT, Brugada paterni |
| İskemi / Enfarktüs | Akut STEMI, NSTEMI/İskemi, Eski MI |
| Kardiyak İnflamasyon | Perikardit, Miyokardit |
| Hipertrofi | Sol ventriküler hipertrofi, Sağ ventriküler hipertrofi |
| Atriyal Büyüme | Sol atriyal büyüme, Sağ atriyal büyüme |
| Elektrolit | Hiperkalemi, Hipokalemi, Hipokalsemi, Hiperkalsemi |
| Sistemik | Akciğer embolisi, Hipotermi / Osborn dalgası |

---

## Referans Görsel

Hastalık kriterleri için kullanılan rehber: [`Odev1_Prolog/Türkçe EKG Hastalıkları Rehberi.png`](<Odev1_Prolog/Türkçe EKG Hastalıkları Rehberi.png>)

---

## Teknoloji

**SWI-Prolog** — Mantık programlama, kural tabanlı uzman sistem
