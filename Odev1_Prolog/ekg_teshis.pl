% ============================================================
%  EKG Hastalık Tespit Sistemi
%  Kaynak: "Farklı Hastalıklarda Tipik EKG Görünümleri (~35 Durum)"
% ============================================================

% ============================================================
% BÖLÜM 1: SİNYAL FAKTLERİ (dinamik yükleme için)
% ============================================================
% Sinyal parametreleri şu formatta tanımlanır:
%   sinyal(ID, Parametre, Deger)
%
% Parametreler:
%   ritim           : duzenli | duzensiz | kaotik
%   hiz             : Sayi (atım/dk)
%   p_dalgasi       : var | yok | sivri | cift_tepeli | testere_disi | anormal | delta
%   pr_suresi       : Sayi (ms)  [normal: 120-200]
%   qrs_suresi      : Sayi (ms)  [normal: 80-120]
%   qrs_morfoloji   : normal | genis | rsR_prime | derin_negatif | bozuk | kaotik
%   qt_suresi       : Sayi (ms)  [QTc cinsinden]
%   st_segment      : normal | elevasyon | depresyon | yaygin_elevasyon
%   t_dalgasi       : normal | sivri | negatif | duzlesmis | hiperakut
%   q_dalgasi       : normal | patolojik
%   u_dalgasi       : yok | var
%   aks             : normal | sol_sapma | sag_sapma
%   v1_morfoloji    : normal | rSR_prime | derin_S | yuksek_R
%   pr_davranis     : sabit | giderek_uzuyor | dusmus_kompleks
%   cinsiyet        : erkek | kadin

% ============================================================
% BÖLÜM 2: YARDIMCI YÜKLEMLER
% ============================================================

hiz_normal(H) :- H >= 60, H =< 100.
hiz_bradikardi(H) :- H < 60.
hiz_tasikardi(H) :- H > 100.
hiz_svt(H) :- H >= 150, H =< 250.
hiz_vt(H) :- H >= 100, H =< 250.

pr_uzun(PR) :- PR > 200.
pr_kisa(PR) :- PR < 120.
pr_normal(PR) :- PR >= 120, PR =< 200.

qrs_genis(QRS) :- QRS >= 120.
qrs_normal(QRS) :- QRS < 120.

qtc_uzun_erkek(QTc) :- QTc > 440.
qtc_uzun_kadin(QTc) :- QTc > 460.
qtc_kisa(QTc) :- QTc < 350.

% ============================================================
% BÖLÜM 3: HASTALIK KURALLARI
% ============================================================

%% --- 1. NORMAL VE SİNÜS RİTİMLERİ ---

% 1. Normal sinüs ritmi
teshis(ID, normal_sinus_ritmi) :-
    sinyal(ID, ritim, duzenli),
    sinyal(ID, p_dalgasi, var),
    sinyal(ID, hiz, H), hiz_normal(H),
    sinyal(ID, pr_suresi, PR), pr_normal(PR),
    sinyal(ID, qrs_suresi, QRS), qrs_normal(QRS),
    sinyal(ID, st_segment, normal),
    sinyal(ID, t_dalgasi, normal).

% 2. Sinüs bradikardisi
teshis(ID, sinus_bradikardisi) :-
    sinyal(ID, ritim, duzenli),
    sinyal(ID, p_dalgasi, var),
    sinyal(ID, hiz, H), hiz_bradikardi(H),
    sinyal(ID, pr_suresi, PR), pr_normal(PR).

% 3. Sinüs taşikardisi
teshis(ID, sinus_tasikardisi) :-
    sinyal(ID, ritim, duzenli),
    sinyal(ID, p_dalgasi, var),
    sinyal(ID, hiz, H), H > 100, H < 150,
    sinyal(ID, pr_suresi, PR), pr_normal(PR).

%% --- 2. ATRİYAL RİTİM BOZUKLUKLARI ---

% 4. Atriyal fibrilasyon
teshis(ID, atriyal_fibrilasyon) :-
    sinyal(ID, ritim, duzensiz),
    sinyal(ID, p_dalgasi, yok),
    sinyal(ID, qrs_suresi, QRS), qrs_normal(QRS).

% 5. Atriyal flutter
teshis(ID, atriyal_flutter) :-
    sinyal(ID, p_dalgasi, testere_disi),
    sinyal(ID, hiz, H), H >= 250, H =< 350.

% 6. SVT (AVNRT/AVRT)
teshis(ID, svt) :-
    sinyal(ID, ritim, duzenli),
    sinyal(ID, qrs_suresi, QRS), qrs_normal(QRS),
    sinyal(ID, hiz, H), hiz_svt(H),
    ( sinyal(ID, p_dalgasi, yok) ; sinyal(ID, p_dalgasi, anormal) ).

%% --- 3. VENTRİKÜLER RİTİM BOZUKLUKLARI ---

% 7. Ventriküler taşikardi (VT)
teshis(ID, ventrikuler_tasikardi) :-
    sinyal(ID, ritim, duzenli),
    sinyal(ID, qrs_suresi, QRS), qrs_genis(QRS),
    sinyal(ID, hiz, H), hiz_vt(H),
    sinyal(ID, qrs_morfoloji, genis).

% 8. Ventriküler fibrilasyon (VF)
teshis(ID, ventrikuler_fibrilasyon) :-
    sinyal(ID, ritim, kaotik),
    sinyal(ID, qrs_morfoloji, kaotik),
    sinyal(ID, p_dalgasi, yok).

% 9. PAC (Supraventriküler erken atım)
teshis(ID, pac_erken_atim) :-
    sinyal(ID, p_dalgasi, anormal),
    sinyal(ID, qrs_suresi, QRS), qrs_normal(QRS),
    sinyal(ID, ritim, duzensiz).

% 10. PVC (Ventriküler erken atım)
teshis(ID, pvc_erken_atim) :-
    sinyal(ID, qrs_morfoloji, bozuk),
    sinyal(ID, qrs_suresi, QRS), qrs_genis(QRS),
    sinyal(ID, ritim, duzensiz).

%% --- 4. AV BLOKLAR ---

% 11. 1. Derece AV blok
teshis(ID, av_blok_1_derece) :-
    sinyal(ID, pr_suresi, PR), pr_uzun(PR),
    sinyal(ID, ritim, duzenli),
    sinyal(ID, p_dalgasi, var),
    sinyal(ID, pr_davranis, sabit).

% 12. Mobitz I (Wenckebach) - 2. Derece AV Blok Tip I
teshis(ID, av_blok_2_derece_mobitz1) :-
    sinyal(ID, pr_davranis, giderek_uzuyor),
    sinyal(ID, pr_davranis, dusmus_kompleks).

% 13. Mobitz II - 2. Derece AV Blok Tip II
teshis(ID, av_blok_2_derece_mobitz2) :-
    sinyal(ID, pr_davranis, sabit),
    sinyal(ID, pr_davranis, dusmus_kompleks),
    sinyal(ID, qrs_suresi, QRS), qrs_genis(QRS).

% 14. Tam AV Blok (3. Derece)
teshis(ID, tam_av_blok_3_derece) :-
    sinyal(ID, p_dalgasi, var),
    sinyal(ID, pr_davranis, bagimsiz),
    sinyal(ID, hiz, H), H < 60.

%% --- 5. DAL BLOKLARI VE İLETİ BOZUKLUKLARI ---

% 15. Sağ dal bloğu (RBBB)
teshis(ID, sag_dal_blogu_rbbb) :-
    sinyal(ID, qrs_suresi, QRS), qrs_genis(QRS),
    sinyal(ID, v1_morfoloji, rSR_prime).

% 16. Sol dal bloğu (LBBB)
teshis(ID, sol_dal_blogu_lbbb) :-
    sinyal(ID, qrs_suresi, QRS), qrs_genis(QRS),
    sinyal(ID, v1_morfoloji, derin_S),
    sinyal(ID, qrs_morfoloji, genis).

% 17. Sol anterior fasiküler blok
teshis(ID, sol_anterior_fasikuler_blok) :-
    sinyal(ID, aks, sol_sapma),
    sinyal(ID, qrs_suresi, QRS), QRS < 120,
    sinyal(ID, p_dalgasi, var).

% 18. WPW (Wolff-Parkinson-White / Preeksitasyon)
teshis(ID, wpw_preeksitasyon) :-
    sinyal(ID, pr_suresi, PR), pr_kisa(PR),
    sinyal(ID, p_dalgasi, delta),
    sinyal(ID, qrs_suresi, QRS), qrs_genis(QRS).

%% --- 6. QT BOZUKLUKLARI ---

% 19. Uzun QT sendromu
teshis(ID, uzun_qt_sendromu) :-
    sinyal(ID, qt_suresi, QTc),
    sinyal(ID, cinsiyet, erkek),
    qtc_uzun_erkek(QTc).

teshis(ID, uzun_qt_sendromu) :-
    sinyal(ID, qt_suresi, QTc),
    sinyal(ID, cinsiyet, kadin),
    qtc_uzun_kadin(QTc).

% 20. Kısa QT sendromu
teshis(ID, kisa_qt_sendromu) :-
    sinyal(ID, qt_suresi, QTc),
    qtc_kisa(QTc).

%% --- 7. ÖZEL PATERNLER ---

% 21. Brugada paterni
teshis(ID, brugada_paterni) :-
    sinyal(ID, st_segment, elevasyon),
    sinyal(ID, v1_morfoloji, rSR_prime),
    sinyal(ID, qrs_morfoloji, genis).

%% --- 8. MİYOKARD İSKEMİSİ VE ENFARKTÜS ---

% 22. Akut STEMI
teshis(ID, akut_stemi) :-
    sinyal(ID, st_segment, elevasyon),
    sinyal(ID, t_dalgasi, hiperakut).

% 23. NSTEMI / İskemi
teshis(ID, nstemi_iskemi) :-
    sinyal(ID, st_segment, depresyon),
    ( sinyal(ID, t_dalgasi, negatif) ; sinyal(ID, t_dalgasi, duzlesmis) ).

% 24. Eski MI
teshis(ID, eski_mi) :-
    sinyal(ID, q_dalgasi, patolojik),
    sinyal(ID, st_segment, normal).

% 25. Perikardit
teshis(ID, perikardit) :-
    sinyal(ID, st_segment, yaygin_elevasyon),
    sinyal(ID, pr_suresi, PR), PR < 200.

% 26. Miyokardit
teshis(ID, miyokardit) :-
    sinyal(ID, st_segment, depresyon),
    sinyal(ID, ritim, duzensiz),
    sinyal(ID, t_dalgasi, negatif).

%% --- 10. KALP BÜYÜMESI (HİPERTROFİ) ---

% 27. Sol ventriküler hipertrofi (SVH)
teshis(ID, sol_ventrikuler_hipertrofi) :-
    sinyal(ID, v1_morfoloji, yuksek_R),
    sinyal(ID, st_segment, depresyon),
    sinyal(ID, t_dalgasi, negatif),
    sinyal(ID, aks, sol_sapma).

% 28. Sağ ventriküler hipertrofi (SVH)
teshis(ID, sag_ventrikuler_hipertrofi) :-
    sinyal(ID, v1_morfoloji, yuksek_R),
    sinyal(ID, aks, sag_sapma).

%% --- 11. ATRİYAL BÜYÜMELER ---

% 29. Sol atriyal büyüme
teshis(ID, sol_atriyal_buyume) :-
    sinyal(ID, p_dalgasi, cift_tepeli),
    sinyal(ID, pr_suresi, PR), PR > 120.

% 30. Sağ atriyal büyüme
teshis(ID, sag_atriyal_buyume) :-
    sinyal(ID, p_dalgasi, sivri).

%% --- 12. ELEKTROLİT BOZUKLUKLARI ---

% 31. Hiperkalemi
teshis(ID, hiperkalemi) :-
    sinyal(ID, t_dalgasi, sivri),
    sinyal(ID, qrs_suresi, QRS), qrs_genis(QRS),
    sinyal(ID, p_dalgasi, yok).

% 32. Hipokalemi
teshis(ID, hipokalemi) :-
    sinyal(ID, t_dalgasi, duzlesmis),
    sinyal(ID, u_dalgasi, var).

% 33. Hipokalsemi
teshis(ID, hipokalsemi) :-
    sinyal(ID, qt_suresi, QTc), qtc_uzun_erkek(QTc),
    \+ sinyal(ID, t_dalgasi, sivri).

% 34. Hiperkalsemi
teshis(ID, hiperkalsemi) :-
    sinyal(ID, qt_suresi, QTc), qtc_kisa(QTc),
    \+ sinyal(ID, u_dalgasi, var).

%% --- 13. DİĞER DURUMLAR ---

% 35. Akciğer embolisi (S1Q3T3 paterni)
teshis(ID, akciger_embolisi) :-
    sinyal(ID, aks, sag_sapma),
    sinyal(ID, hiz, H), hiz_tasikardi(H),
    sinyal(ID, p_dalgasi, var).

% 36. Hipotermi (J/Osborn dalgası)
teshis(ID, hipotermi_osborn) :-
    sinyal(ID, p_dalgasi, delta),   % J dalgası için delta olarak temsil
    sinyal(ID, hiz, H), hiz_bradikardi(H).

% ============================================================
% BÖLÜM 4: TOPLU TEŞHİS YÜKLEMLERI
% ============================================================

% Bir hasta için tüm eşleşen teşhisleri bul
tum_teshisler(ID, Teshisler) :-
    findall(T, teshis(ID, T), Teshisler0),
    sort(Teshisler0, Teshisler).

% Teşhis sonuçlarını ekrana yaz
teshis_raporu(ID) :-
    format("~n=== EKG Teşhis Raporu: Hasta ~w ===~n", [ID]),
    tum_teshisler(ID, Teshisler),
    ( Teshisler = [] ->
        format("Teşhis bulunamadi veya veriler yetersiz.~n")
    ;
        length(Teshisler, N),
        format("Bulunan teşhis sayisi: ~w~n~n", [N]),
        forall(member(T, Teshisler),
               format("  [+] ~w~n", [T]))
    ),
    format("~n").

% ============================================================
% BÖLÜM 5: ÖRNEK HASTA VERİLERİ
% ============================================================

% --- Hasta 1: Normal Sinüs Ritmi ---
sinyal(hasta1, ritim, duzenli).
sinyal(hasta1, hiz, 72).
sinyal(hasta1, p_dalgasi, var).
sinyal(hasta1, pr_suresi, 160).
sinyal(hasta1, qrs_suresi, 90).
sinyal(hasta1, qrs_morfoloji, normal).
sinyal(hasta1, qt_suresi, 400).
sinyal(hasta1, st_segment, normal).
sinyal(hasta1, t_dalgasi, normal).
sinyal(hasta1, q_dalgasi, normal).
sinyal(hasta1, u_dalgasi, yok).
sinyal(hasta1, aks, normal).
sinyal(hasta1, v1_morfoloji, normal).
sinyal(hasta1, pr_davranis, sabit).
sinyal(hasta1, cinsiyet, erkek).

% --- Hasta 2: Atriyal Fibrilasyon ---
sinyal(hasta2, ritim, duzensiz).
sinyal(hasta2, hiz, 110).
sinyal(hasta2, p_dalgasi, yok).
sinyal(hasta2, pr_suresi, 160).
sinyal(hasta2, qrs_suresi, 95).
sinyal(hasta2, qrs_morfoloji, normal).
sinyal(hasta2, qt_suresi, 380).
sinyal(hasta2, st_segment, normal).
sinyal(hasta2, t_dalgasi, normal).
sinyal(hasta2, q_dalgasi, normal).
sinyal(hasta2, u_dalgasi, yok).
sinyal(hasta2, aks, normal).
sinyal(hasta2, v1_morfoloji, normal).
sinyal(hasta2, pr_davranis, sabit).
sinyal(hasta2, cinsiyet, kadin).

% --- Hasta 3: Akut STEMI ---
sinyal(hasta3, ritim, duzenli).
sinyal(hasta3, hiz, 88).
sinyal(hasta3, p_dalgasi, var).
sinyal(hasta3, pr_suresi, 165).
sinyal(hasta3, qrs_suresi, 100).
sinyal(hasta3, qrs_morfoloji, normal).
sinyal(hasta3, qt_suresi, 420).
sinyal(hasta3, st_segment, elevasyon).
sinyal(hasta3, t_dalgasi, hiperakut).
sinyal(hasta3, q_dalgasi, normal).
sinyal(hasta3, u_dalgasi, yok).
sinyal(hasta3, aks, normal).
sinyal(hasta3, v1_morfoloji, normal).
sinyal(hasta3, pr_davranis, sabit).
sinyal(hasta3, cinsiyet, erkek).

% --- Hasta 4: Ventriküler Taşikardi ---
sinyal(hasta4, ritim, duzenli).
sinyal(hasta4, hiz, 180).
sinyal(hasta4, p_dalgasi, yok).
sinyal(hasta4, pr_suresi, 160).
sinyal(hasta4, qrs_suresi, 140).
sinyal(hasta4, qrs_morfoloji, genis).
sinyal(hasta4, qt_suresi, 380).
sinyal(hasta4, st_segment, normal).
sinyal(hasta4, t_dalgasi, normal).
sinyal(hasta4, q_dalgasi, normal).
sinyal(hasta4, u_dalgasi, yok).
sinyal(hasta4, aks, normal).
sinyal(hasta4, v1_morfoloji, normal).
sinyal(hasta4, pr_davranis, sabit).
sinyal(hasta4, cinsiyet, erkek).

% --- Hasta 5: Sinüs Bradikardisi ---
sinyal(hasta5, ritim, duzenli).
sinyal(hasta5, hiz, 45).
sinyal(hasta5, p_dalgasi, var).
sinyal(hasta5, pr_suresi, 170).
sinyal(hasta5, qrs_suresi, 90).
sinyal(hasta5, qrs_morfoloji, normal).
sinyal(hasta5, qt_suresi, 430).
sinyal(hasta5, st_segment, normal).
sinyal(hasta5, t_dalgasi, normal).
sinyal(hasta5, q_dalgasi, normal).
sinyal(hasta5, u_dalgasi, yok).
sinyal(hasta5, aks, normal).
sinyal(hasta5, v1_morfoloji, normal).
sinyal(hasta5, pr_davranis, sabit).
sinyal(hasta5, cinsiyet, kadin).

% --- Hasta 6: Sağ Dal Bloğu (RBBB) ---
sinyal(hasta6, ritim, duzenli).
sinyal(hasta6, hiz, 78).
sinyal(hasta6, p_dalgasi, var).
sinyal(hasta6, pr_suresi, 175).
sinyal(hasta6, qrs_suresi, 130).
sinyal(hasta6, qrs_morfoloji, genis).
sinyal(hasta6, qt_suresi, 410).
sinyal(hasta6, st_segment, normal).
sinyal(hasta6, t_dalgasi, normal).
sinyal(hasta6, q_dalgasi, normal).
sinyal(hasta6, u_dalgasi, yok).
sinyal(hasta6, aks, sag_sapma).
sinyal(hasta6, v1_morfoloji, rSR_prime).
sinyal(hasta6, pr_davranis, sabit).
sinyal(hasta6, cinsiyet, erkek).

% --- Hasta 7: Hipokalemi ---
sinyal(hasta7, ritim, duzenli).
sinyal(hasta7, hiz, 75).
sinyal(hasta7, p_dalgasi, var).
sinyal(hasta7, pr_suresi, 165).
sinyal(hasta7, qrs_suresi, 95).
sinyal(hasta7, qrs_morfoloji, normal).
sinyal(hasta7, qt_suresi, 420).
sinyal(hasta7, st_segment, depresyon).
sinyal(hasta7, t_dalgasi, duzlesmis).
sinyal(hasta7, q_dalgasi, normal).
sinyal(hasta7, u_dalgasi, var).
sinyal(hasta7, aks, normal).
sinyal(hasta7, v1_morfoloji, normal).
sinyal(hasta7, pr_davranis, sabit).
sinyal(hasta7, cinsiyet, kadin).

% --- Hasta 8: Ventriküler Fibrilasyon ---
sinyal(hasta8, ritim, kaotik).
sinyal(hasta8, hiz, 300).
sinyal(hasta8, p_dalgasi, yok).
sinyal(hasta8, pr_suresi, 0).
sinyal(hasta8, qrs_suresi, 200).
sinyal(hasta8, qrs_morfoloji, kaotik).
sinyal(hasta8, qt_suresi, 0).
sinyal(hasta8, st_segment, normal).
sinyal(hasta8, t_dalgasi, normal).
sinyal(hasta8, q_dalgasi, normal).
sinyal(hasta8, u_dalgasi, yok).
sinyal(hasta8, aks, normal).
sinyal(hasta8, v1_morfoloji, normal).
sinyal(hasta8, pr_davranis, bagimsiz).
sinyal(hasta8, cinsiyet, erkek).

% --- Hasta 9: WPW (Preeksitasyon) ---
sinyal(hasta9, ritim, duzenli).
sinyal(hasta9, hiz, 85).
sinyal(hasta9, p_dalgasi, delta).
sinyal(hasta9, pr_suresi, 100).
sinyal(hasta9, qrs_suresi, 130).
sinyal(hasta9, qrs_morfoloji, genis).
sinyal(hasta9, qt_suresi, 380).
sinyal(hasta9, st_segment, normal).
sinyal(hasta9, t_dalgasi, normal).
sinyal(hasta9, q_dalgasi, normal).
sinyal(hasta9, u_dalgasi, yok).
sinyal(hasta9, aks, normal).
sinyal(hasta9, v1_morfoloji, normal).
sinyal(hasta9, pr_davranis, sabit).
sinyal(hasta9, cinsiyet, erkek).

% --- Hasta 10: Perikardit ---
sinyal(hasta10, ritim, duzenli).
sinyal(hasta10, hiz, 92).
sinyal(hasta10, p_dalgasi, var).
sinyal(hasta10, pr_suresi, 185).
sinyal(hasta10, qrs_suresi, 95).
sinyal(hasta10, qrs_morfoloji, normal).
sinyal(hasta10, qt_suresi, 390).
sinyal(hasta10, st_segment, yaygin_elevasyon).
sinyal(hasta10, t_dalgasi, normal).
sinyal(hasta10, q_dalgasi, normal).
sinyal(hasta10, u_dalgasi, yok).
sinyal(hasta10, aks, normal).
sinyal(hasta10, v1_morfoloji, normal).
sinyal(hasta10, pr_davranis, sabit).
sinyal(hasta10, cinsiyet, kadin).

% ============================================================
% BÖLÜM 6: HASTALIK AÇIKLAMALARI
% ============================================================

aciklama(normal_sinus_ritmi,
    "Duzenli ritim, P her QRS oncesinde, Hiz 60-100/dk").
aciklama(sinus_bradikardisi,
    "Duzenli ritim, P her QRS oncesinde, Hiz < 60/dk").
aciklama(sinus_tasikardisi,
    "Duzenli ritim, P her QRS oncesinde, Hiz > 100/dk").
aciklama(atriyal_fibrilasyon,
    "P dalgasi yok, RR araliklarinda duzensizlik (duzensiz duzensizlik)").
aciklama(atriyal_flutter,
    "Testere disi F dalgalari, genellikle 2:1 veya 3:1 iletim").
aciklama(svt,
    "Duzenli dar QRS tasikardisi, P genellikle secilemez, Hiz 150-250/dk").
aciklama(ventrikuler_tasikardi,
    "Genis QRS'li hizli ritim, duzenli, Hiz 100-250/dk").
aciklama(ventrikuler_fibrilasyon,
    "Organize QRS yok, kaotik aktivite, nabizli olabilir").
aciklama(pac_erken_atim,
    "Erken gelen anormal P, genellikle dar QRS").
aciklama(pvc_erken_atim,
    "Erken, genis ve sekli bozuk QRS, kompansatuvar poz").
aciklama(av_blok_1_derece,
    "PR suresi > 200 ms, her P'yi QRS takip eder").
aciklama(av_blok_2_derece_mobitz1,
    "PR giderek uzar, sonra QRS duser (Wenckebach)").
aciklama(av_blok_2_derece_mobitz2,
    "Sabit PR, bazilan QRS'ler duser, genis QRS olabilir").
aciklama(tam_av_blok_3_derece,
    "P ve QRS birbirinden bagimsiz, atriyal ve ventrikuler ritim ayri").
aciklama(sag_dal_blogu_rbbb,
    "QRS >= 120 ms, V1'de rSR' paterni").
aciklama(sol_dal_blogu_lbbb,
    "Genis QRS >= 120 ms, V1'de derin negatif, V5-V6'da genis R").
aciklama(sol_anterior_fasikuler_blok,
    "Sol aks sapmasi (-45 ile -90 derece), QRS < 120 ms").
aciklama(wpw_preeksitasyon,
    "Kisa PR < 120 ms, delta dalgasi, genis QRS").
aciklama(uzun_qt_sendromu,
    "QTc > 440 ms (erkek), QTc > 460 ms (kadin)").
aciklama(kisa_qt_sendromu,
    "QTc < 350 ms").
aciklama(brugada_paterni,
    "V1-V3'te ST elevasyonu, tipik kovvet goruntumu").
aciklama(akut_stemi,
    "Komsu derivasyonlarda ST elevasyonu, genellikle hiperakut T").
aciklama(nstemi_iskemi,
    "ST depresyonu ve/veya T negativligi").
aciklama(eski_mi,
    "Patolojik Q dalgalari (>= 0.04 sn ve derin)").
aciklama(perikardit,
    "Yaygin ST elevasyonu, PR depresyonu").
aciklama(miyokardit,
    "Nonspesifik ST-T degisiklikleri, aritmiler eslik edebilir").
aciklama(sol_ventrikuler_hipertrofi,
    "Yuksek QRS voltaji, ST depresyonu, T negativligi (strain)").
aciklama(sag_ventrikuler_hipertrofi,
    "Sag aks sapmasi, V1'de yuksek R").
aciklama(sol_atriyal_buyume,
    "Genis, cift tepeli P dalgasi (> 120 ms, en belirgin DI)").
aciklama(sag_atriyal_buyume,
    "Sivri, yuksek P dalgasi (>= 2.5 mm, DII DIII aVF'de)").
aciklama(hiperkalemi,
    "Sivri yuksek T dalgalari, QRS genislemesi, P kaybi").
aciklama(hipokalemi,
    "Duzlesmis T, belirgin U dalgasi").
aciklama(hipokalsemi,
    "QT uzamasi").
aciklama(hiperkalsemi,
    "Kisa QT").
aciklama(akciger_embolisi,
    "S1Q3T3 paterni, sinus tasikardisi, sag kalp bulgulari").
aciklama(hipotermi_osborn,
    "J (Osborn) dalgasi, bradikardi").

% Açıklamalı rapor
aciklamali_rapor(ID) :-
    format("~n========================================~n"),
    format("  EKG TESHIS RAPORU - Hasta: ~w~n", [ID]),
    format("========================================~n"),
    tum_teshisler(ID, Teshisler),
    ( Teshisler = [] ->
        format("  Teshis eslesmesi bulunamadi.~n")
    ;
        length(Teshisler, N),
        format("  Toplam ~w teshis bulundu:~n~n", [N]),
        forall(member(T, Teshisler), (
            aciklama(T, Acik),
            format("  [TESHIS] ~w~n", [T]),
            format("  [BILGI ] ~w~n~n", [Acik])
        ))
    ),
    format("========================================~n~n").

% Tüm hastaları tara
tum_hastalar_raporu :-
    findall(ID, sinyal(ID, hiz, _), IDs0),
    sort(IDs0, IDs),
    forall(member(ID, IDs), aciklamali_rapor(ID)).

% ============================================================
% BÖLÜM 7: İNTERAKTİF SORGULAMA
% ============================================================

% Belirli bir hastalığı olan hastaları bul
hastaliği_olan_hastalar(Hastalik) :-
    format("~n'~w' tespit edilen hastalar:~n", [Hastalik]),
    findall(ID, teshis(ID, Hastalik), IDs),
    ( IDs = [] ->
        format("  Kayitli hastalar arasinda bu teshis bulunamadi.~n")
    ;
        forall(member(ID, IDs), format("  - ~w~n", [ID]))
    ).

% Acil durumları filtrele
acil_durumlar :-
    format("~n=== ACİL EKG DURUMLARI ===~n"),
    AcilTeshisler = [ventrikuler_fibrilasyon, ventrikuler_tasikardi,
                     akut_stemi, tam_av_blok_3_derece],
    forall(member(T, AcilTeshisler), (
        findall(ID, teshis(ID, T), IDs),
        ( IDs \= [] ->
            format("~n[!] ~w:~n", [T]),
            forall(member(ID, IDs), format("    -> Hasta: ~w~n", [ID]))
        ;
            true
        )
    )).

% ============================================================
% KULLANIM ÖRNEKLERİ:
%
%  ?- teshis_raporu(hasta1).
%  ?- teshis_raporu(hasta3).
%  ?- aciklamali_rapor(hasta4).
%  ?- tum_hastalar_raporu.
%  ?- hastaliği_olan_hastalar(atriyal_fibrilasyon).
%  ?- acil_durumlar.
%  ?- teshis(hasta2, X).
% ============================================================
