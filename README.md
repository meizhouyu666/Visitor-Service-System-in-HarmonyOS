# HarmonyOS 濞撶顓归張宥呭缁崵绮?

閺堫兛绮ㄦ惔鎾存Ц濞撶顓归張宥呭缁崵绮虹拠鍓р柤妞ゅ湱娲伴惃鍕礋娴犳挷鍞惍浣哥氨閿涘湣onorepo閿涘鈧?

## 娴犳挸绨辩紒鎾寸€?

- `backend/`閿涙瓔pring Boot + MySQL + JWT + OpenAPI
- `frontend/harmony-app/`閿涙armonyOS ArkTS 閸撳秶顏銊︾仸閿涘湯tage Model閿?
- `docs/`閿涙碍娓剁亸蹇斿复閸欙絽顨栫痪锔跨瑢濞村鐦潻鎰攽閺傚洦銆?

## 韫囶偊鈧喎绱戞慨?

1. 閸忓娈曟禒鎾崇氨閵?
2. 閸掓稑缂撻懛顏勭箒閻ㄥ嫬濮涢懗钘夊瀻閺€顖樷偓?
3. 瀵偓閸欐垵顕惔鏃€膩閸ф鑻熼幒銊┾偓浣稿瀻閺€顖樷偓?
4. 閸欐垼鎹ｉ崥鍫濊嫙閸?`main` 閻?Pull Request閵?

## 閸掑棙鏁崨钘夋倳鐟欏嫯瀵?

- 閸旂喕鍏橀崚鍡樻暜閿涙瓪feature/<module>-<task>`
- 娣囶喖顦查崚鍡樻暜閿涙瓪fix/<module>-<issue>`

## 閸氬海顏崥顖氬З

```bash
cd backend
docker compose up -d
mvn spring-boot:run
```

Swagger 妞ょ敻娼伴敍?

- `http://localhost:8080/swagger-ui.html`

## 閸撳秶顏拠瀛樻

- 閸?DevEco Studio 娑擃厽澧﹀鈧?`frontend/harmony-app`閵?
- 姒涙顓诲鏃傘仛鐠愶箑褰块敍?
  - 濞撶顓归敍姝歷isitor / visitor123`
  - 缁狅紕鎮婇崨姗堢窗`admin / admin123`

## 閻楀牊婀扮拠瀛樻閿?026-04-17閿?

### v0.2.0閿涘牓妯佸▓鍏哥癌閸撳秴鎮楃粩顖滅埠娑撯偓閻楀牞绱?

閺堫剛澧楅張顒€鎮庨獮鏈电啊閺堫剚妫╂稉銈嗩偧閹恒劑鈧緤绱濋惄顔界垼閺勵垰鐨㈡い鍦窗娴犲簶鈧粓顎囬弸鍫曟▉濞堢鈧繃甯规潻娑樺煂閳ユ粌褰查懕鏃囩殶濠曟梻銇氶梼鑸殿唽閳ユ繐绱濋獮璺虹暚閹存劕澧犻崥搴ｎ伂鐟欐帟澹婃稉搴㈠复閸欙絿绮烘稉鈧妴?

1. 閸撳秶顏弴瀛樻煀閿涘牊褰佹禍銈忕窗`0ac6c40`閿?
- 鐎瑰本鍨氶崗顓☆潡閼规彃顕遍懜顏冪瑢閸忋儱褰涢崚鍡欘瀲閿涘牆鎯?`ADMIN` 閸忕厧顔愰敍澶堚偓?
- 閽€钘夋勾閹舵洝鐦旀稉濠氭懠鐠侯垶銆夐棃銏ｅ厴閸旀冻绱伴幓鎰唉閵嗕礁鍨悰銊ｂ偓浣筋嚊閹懎鐫嶇粈鎭掆偓浣割吀閹靛箍鈧礁顦╅悶鍡愨偓浣虹波濡楀牄鈧浇鐦庢禒鏋偓?
- 閽€钘夋勾鎼存梹鈧儰瀵岄柧鎹愮熅妞ょ敻娼伴懗钘夊閿涙艾缂撶粙瑁も偓浣虹椽鏉堟垯鈧焦褰佹禍銈咁吀閹靛箍鈧礁顓搁幍鐟板絺鐢啨鈧焦鐖剁€广垺鐓＄拠顫偓?
- 閺屻儴顕楀Ο鈥虫健閸掑洦宕查懛铏煀閹恒儱褰涚拫鍐暏閿涘牓鍘惔?閺咁垰灏痪鑳熅/妞佹劙銈繛鍙樼濠曟柨鍤?婢垛晜鐨电捄顖氬枌閿涘鈧?
- 閸旂姴宸辨禒鎾崇氨閸楊偆鏁撻敍姘嫹閻?`entry/.preview/` 娑?`oh_modules/`閿涘矂浼╅崗宥勯獓閻椻晜钖勯弻鎾扁偓?

2. 閸氬海顏弴瀛樻煀閿涘牊褰佹禍銈忕窗`2dd4b12`閿?
- 鐟欐帟澹婃担鎾堕兇閹碘晛鐫嶆稉鐚寸窗`VISITOR`閵嗕梗COMPLAINT_HANDLER`閵嗕梗EMERGENCY_WRITER`閵嗕梗APPROVER`閵嗕梗HOTEL_MANAGER`閵嗕梗SYSTEM_ADMIN`閵嗕梗ADMIN`閵?
- 缂佺喍绔撮幎鏇＄様娑撳骸绨查幀銉δ侀崸妤佹綀闂勬劘绔熼悾宀嬬礄閺傝纭剁痪褔澹岄弶鍐跨礉缁狅紕鎮婇崨妯哄幑鎼存洩绱氶妴?
- 閺傛澘顤冮獮璺虹磻閺€鐐叀鐠囥垺鏌婄捄顖滄暠閿?
  - `/api/query/hotels`
  - `/api/query/scenic-spots`
  - `/api/query/routes`
  - `/api/query/dining`
  - `/api/query/entertainment`
  - `/api/query/performances`
  - `/api/query/weather`
  - `/api/query/traffic`
- 娣囨繄鏆€閺冄勭叀鐠囥垼鐭鹃悽鍗炲悑鐎圭櫢绱濋柆鍨帳閺冄冨缁旑垵鐨熼悽銊х彌閸楀厖鑵戦弬顓溾偓?
- 婢х偛濮炴径姘愁潡閼瑰弶绱ㄧ粈楦垮閸欏嘲鍨垫慨瀣閿涘潉handler/writer/approver/hoteladmin/sysadmin`閿涘鈧?

3. 瀹歌尙鐓℃禍瀣€?
- 閺堫剛澧楅張顒佸瘻閸楀繋缍旂痪锕€鐣鹃張顏呭⒔鐞涘本婀伴崷?build/濡剝瀚欓崳銊╃崣鐠囦緤绱濋棁鈧悽杈ㄧゴ鐠囨洖鎮撶€涳箑婀?DevEco 娑撳骸鎮楃粩顖滃箚婢у啩鑵戦崶鐐茬秺閵?
- 闂団偓閹镐胶鐢婚柆鍨帳閹绘劒姘﹂張顒佹簚娴溠呭⒖娑撳簼閲滄禍铏瑰箚婢у啴鍘ょ純顕嗙礄婵?`.preview`閵嗕梗oh_modules`閵嗕椒閲滄禍?IP閵嗕椒閲滄禍鍝勭槕閻緤绱氶妴?



## Version Note (2026-04-18)

### v0.2.1 (Requirements Gap Delivery Package)
- Goal: deliver a reviewable gap-analysis package between requirement docs and current codebase.
- Main changes:
  - docs/requirements-gap-delivery.md
  - docs/requirements-traceability-matrix.md
  - docs/gap-backlog.md
  - docs/api-compatibility-diff.md
  - docs/db-migration-incremental-plan.md
  - docs/release-collaboration-gates.md
- API compatibility: this release only adds documentation; no runtime API behavior changed.
- Config impact:
  - [OK] teammates can pull latest without changing local configuration
  - [OK] startup steps and ports remain unchanged
- Rollback: revert added docs and this README section.
