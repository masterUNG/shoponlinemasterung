# Shop Online Master Ung

แอปซื้อขายสินค้าออนไลน์สำหรับร้านค้าขนาดเล็ก พัฒนาด้วย Flutter โดยแยกการใช้งานเป็น 2 ส่วน:

- แอปลูกค้าบน Android/iOS สำหรับดูสินค้า สั่งซื้อ ชำระเงิน และติดตามออเดอร์
- ระบบผู้ดูแลบน Flutter Web สำหรับจัดการสินค้า สต๊อก ออเดอร์ และตรวจสลิป

ข้อมูลหลักทำงานแบบ real-time ผ่าน Firebase Authentication และ Cloud Firestore

## สถานะโปรเจกต์ปัจจุบัน

อัปเดตล่าสุด: **13 มิถุนายน 2026**

สถานะโดยรวม: **ระบบหลักพร้อมใช้งานจริงในระดับ MVP** ทั้งแอปลูกค้าและ
Admin Web โดย flow ซื้อสินค้า ตัดสต๊อก ตรวจสลิป ยกเลิกออเดอร์
และคืนสต๊อกทำงานแล้ว งานที่เหลือเน้นการรองรับระบบที่โตขึ้น
การชำระเงินอัตโนมัติ การแจ้งเตือน และการเพิ่มชุดทดสอบ

ระบบ Admin Web ที่ deploy ล่าสุด:
<https://shopinglinemasterung.web.app>

เวอร์ชันที่ตั้งค่าในแต่ละแพลตฟอร์ม:

| แพลตฟอร์ม | Version | Build |
| --- | --- | --- |
| Android | `1.0.8` | `8` |
| iOS | `1.0.4` | `4` |
| Flutter (`pubspec.yaml`) | `1.0.0` | `1` |

> หมายเหตุ: เวอร์ชันใน `pubspec.yaml`, Android และ iOS ยังไม่ตรงกัน
> ควรปรับให้ใช้แหล่งกำหนดเวอร์ชันเดียวกันก่อน release รอบถัดไป

ระบบหลักที่มีอยู่ในโค้ด:

| ส่วนงาน | สถานะ |
| --- | --- |
| สมัครสมาชิกและเข้าสู่ระบบด้วย Email/Password | ใช้งานแล้ว |
| Guest reviewer mode | ใช้งานแล้ว |
| แสดงสินค้าแบบ real-time | ใช้งานแล้ว |
| ตะกร้าสินค้าและตรวจจำนวนสต๊อก | ใช้งานแล้ว |
| สร้างออเดอร์และตัดสต๊อกด้วย Firestore transaction | ใช้งานแล้ว |
| ยกเลิกออเดอร์และคืนสต๊อกด้วย Firestore transaction | ใช้งานแล้ว |
| รับสินค้าเองหรือส่งฟรีในรัศมี 1 กม. | ใช้งานแล้ว |
| ชำระผ่าน QR PromptPay และอัปโหลดสลิป | ใช้งานแล้ว |
| ติดตามสถานะออเดอร์ | ใช้งานแล้ว |
| Admin Web และระบบ role | ใช้งานแล้ว |
| เพิ่ม แก้ไข และลบสินค้า | ใช้งานแล้ว |
| ตรวจหรือปฏิเสธสลิป | ใช้งานแล้ว |
| Dashboard ยอดขายวันนี้และเทียบเมื่อวาน | ใช้งานแล้ว |
| กราฟและรายงานยอดขายย้อนหลัง | ยังไม่มี |
| Payment gateway อัตโนมัติ | ยังไม่มี |
| Push notification | ยังไม่มี |
| Automated tests | เริ่มต้นแล้ว (มี 3 tests) |
| Firebase Hosting และ Firestore Rules | Deploy แล้ว |

### ความคืบหน้าล่าสุด

- อัปเดต Android เป็นเวอร์ชัน `1.0.8` build `8`
- อัปเดต iOS เป็นเวอร์ชัน `1.0.4` build `4`
- เพิ่มการลบบัญชีผู้ใช้ พร้อมลบโปรไฟล์และข้อมูลตะกร้า
- เพิ่ม Guest reviewer mode สำหรับทดลองดูสินค้าและใช้งานตะกร้า
- ปรับหน้า Login, Branding, App icon และ Launch screen
- เพิ่มหน้า Support และอัปเดต Privacy Policy
- ปรับ Bottom navigation ฝั่งลูกค้าให้รองรับ SafeArea และพื้นที่ด้านล่างของอุปกรณ์
- แก้ Dashboard ให้คำนวณยอดขายวันนี้จากออเดอร์ที่ชำระแล้วและไม่ถูกยกเลิก
- คำนวณเปอร์เซ็นต์ยอดขายเทียบกับเมื่อวานจากข้อมูลจริง
- คืนสต๊อกอัตโนมัติเมื่อ Admin ยกเลิกออเดอร์ด้วย Firestore transaction
- ป้องกันการคืนสต๊อกซ้ำด้วย field `stockRestoredAt`
- เพิ่ม dialog ยืนยันก่อนยกเลิก และอนุญาตให้ยกเลิกออเดอร์ที่ยังไม่ชำระ
  หรือกำลังรอตรวจสลิป
- ป้องกันการตรวจสลิปชนกับการยกเลิกออเดอร์จากหลายหน้าจอ
- Deploy Firestore Rules และ Admin Web เวอร์ชันล่าสุดขึ้น Firebase แล้ว

### ผลตรวจคุณภาพล่าสุด

ตรวจเมื่อวันที่ **13 มิถุนายน 2026**:

```text
flutter analyze -> No issues found
flutter test    -> All tests passed (3 tests)
```

ข้อควรติดตาม: package `image_gallery_saver_plus` ยังไม่รองรับ Swift Package
Manager สำหรับ iOS และ Flutter แจ้งว่าอาจกลายเป็น error ในเวอร์ชันอนาคต

## ฟีเจอร์ฝั่งลูกค้า

### บัญชีผู้ใช้

- สมัครสมาชิกด้วยชื่อ รูป Avatar อีเมล และรหัสผ่าน
- เข้าสู่ระบบและออกจากระบบด้วย Firebase Authentication
- เก็บโปรไฟล์และ role ที่ `users/{uid}`
- ขอสิทธิ์ Location และบันทึกพิกัดลูกค้าใน Firestore
- ลบบัญชี โปรไฟล์ และข้อมูลในตะกร้า
- Guest reviewer mode เปิดดูสินค้าและทดลองตะกร้าได้โดยไม่บันทึกข้อมูลจริง

### Mall

- อ่านสินค้าจาก collection `product` แบบ real-time
- แสดงรูป ชื่อ รายละเอียด ราคา หน่วย และจำนวนคงเหลือ
- แจ้งสถานะสินค้าใกล้หมดเมื่อเหลือไม่เกิน 5 ชิ้น
- ไม่อนุญาตให้เลือกสินค้าที่หมด
- เลือกจำนวนก่อนเพิ่มลงตะกร้า และจำกัดจำนวนตามสต๊อก

### Cart และการสร้างออเดอร์

- ตะกร้าของแต่ละคนอยู่ที่ `users/{uid}/cart/{productId}`
- เพิ่ม ลด เปลี่ยนจำนวน และลบสินค้า
- คำนวณจำนวนสินค้าและยอดรวม
- เลือกรับสินค้าเองที่ร้าน
- เลือกส่งฟรีได้เมื่อพิกัดลูกค้าอยู่ไม่เกิน 1 กม. จากพิกัดร้าน
- ตรวจสต๊อกอีกครั้งก่อนสั่งซื้อ
- สร้างออเดอร์ ตัดสต๊อก และล้างตะกร้าใน Firestore transaction เดียว
- สร้างเลขออเดอร์รูปแบบ `ORD-YYYYMMDD-XXXXXX`

### Order และการชำระเงิน

- แยกออเดอร์ที่กำลังดำเนินการออกจากออเดอร์ที่เสร็จหรือยกเลิก
- แสดงรายละเอียดสินค้า ยอดชำระ และสถานะล่าสุดแบบ real-time
- แสดง QR PromptPay จาก `images/promptpay.JPG`
- บันทึก QR ลง Gallery บนอุปกรณ์
- เลือกรูปสลิปจาก Gallery และส่งให้ร้านตรวจ
- อัปโหลดสลิปใหม่ได้เมื่อยังไม่ชำระหรือสลิปถูกปฏิเสธ

สถานะออเดอร์:

```text
pending -> accepted -> preparing -> ready -> completed
                     \-> cancelled
```

สถานะการชำระเงิน:

```text
unpaid -> waiting_verify -> paid
                         \-> rejected -> waiting_verify
```

## ฟีเจอร์ฝั่ง Admin Web

เมื่อรันบน Web แอปจะเปิดหน้า Admin Login โดยอัตโนมัติ

- ตรวจสิทธิ์จาก `users/{uid}.role == "admin"`
- Dashboard แสดงยอดขายวันนี้ เปรียบเทียบเมื่อวาน จำนวนออเดอร์เปิด
  สินค้าทั้งหมด และสินค้าใกล้หมด
- ดูสินค้าและออเดอร์จาก Firestore แบบ real-time
- เพิ่มสินค้าใหม่พร้อมรูป ชื่อ รายละเอียด ราคา หน่วย และสต๊อก
- แก้ไขข้อมูลสินค้า ราคา รูป และสต๊อก
- แสดงสินค้า Active, Low stock และ Out of stock
- ดูรายละเอียดออเดอร์ รายการสินค้า ข้อมูลผู้รับ และพิกัดจัดส่ง
- เปลี่ยนสถานะออเดอร์ตามลำดับงาน
- ยกเลิกออเดอร์และคืนสต๊อกอัตโนมัติ โดยป้องกันการคืนซ้ำ
- เปิดดู ยืนยัน หรือปฏิเสธสลิปการชำระเงิน
- ลบสินค้าได้เฉพาะ admin อีเมลที่กำหนดในระบบ

## เทคโนโลยีที่ใช้

- Flutter และ Dart
- Material 3
- GetX สำหรับ routing, binding และ state management
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Image Picker
- Geolocator
- Image Gallery Saver Plus
- Firebase Hosting สำหรับ Admin Web

## โครงสร้างโปรเจกต์

```text
lib/
├── app/routes/                 # GetX routes
├── core/                       # ค่าคงที่ สี และพิกัดร้าน
├── model/                      # User, Product และ Order models
├── services/                   # Admin role และ Guest reviewer mode
├── modules/
│   ├── login/                  # Login/Register ลูกค้า
│   ├── main_home/              # Bottom navigation ฝั่งลูกค้า
│   ├── mall/                   # รายการสินค้า
│   ├── cart/                   # ตะกร้าและสร้างออเดอร์
│   ├── order/                  # ประวัติออเดอร์และชำระเงิน
│   ├── profile/                # โปรไฟล์ Location และลบบัญชี
│   ├── login_admin_web/        # Login ผู้ดูแล
│   └── main_home_web/          # Dashboard และระบบหลังบ้าน
├── firebase_options.dart
└── main.dart
```

## โครงสร้างข้อมูล Firestore

### `users/{uid}`

```json
{
  "uid": "firebase-auth-uid",
  "displayname": "Customer Name",
  "base64avatar": "BASE64_IMAGE",
  "role": "customer",
  "geopoint": "GeoPoint (optional)"
}
```

### `users/{uid}/cart/{productId}`

```json
{
  "productId": "product-document-id",
  "name": "Product name",
  "description": "Description",
  "base64Image": "BASE64_IMAGE",
  "unit": "ชิ้น",
  "price": 100,
  "stock": 10,
  "quantity": 2,
  "addedAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### `product/{productId}`

```json
{
  "name": "Product name",
  "description": "Description",
  "base64Image": "BASE64_IMAGE",
  "unit": "ชิ้น",
  "price": 100,
  "stock": 10,
  "timestamp": "Timestamp"
}
```

### `orders/{orderId}`

ข้อมูลสำคัญประกอบด้วย:

- `orderNo`, `userId`, `userName`, `userPhone`
- `orderType`: `pickup` หรือ `delivery`
- `items`, `subtotal`, `discount`, `grandTotal`
- `deliveryLocation` และ `deliveryDistanceMeters` เมื่อเลือกจัดส่ง
- `status` และ `paymentStatus`
- `paymentSlipBase64`
- `stockRestoredAt` เมื่อยกเลิกออเดอร์และคืนสต๊อกสำเร็จ
- `pickupInfo`
- `createdAt` และ `updatedAt`

## การตั้งค่าและรันโปรเจกต์

สิ่งที่ต้องมี:

- Flutter SDK ที่รองรับ Dart `^3.11.4`
- Firebase project
- เปิดใช้งาน Email/Password ใน Firebase Authentication
- สร้าง Cloud Firestore database
- FlutterFire CLI และ Firebase CLI สำหรับเปลี่ยน Firebase project หรือ deploy

ติดตั้ง dependencies:

```sh
flutter pub get
```

รันแอปลูกค้าบนมือถือ:

```sh
flutter run
```

รันระบบ Admin บน Web:

```sh
flutter run -d chrome
```

ตรวจสอบโค้ดและทดสอบ:

```sh
flutter analyze
flutter test
```

Build และ deploy Web:

```sh
flutter build web
firebase deploy --only hosting
```

Deploy Firestore Security Rules:

```sh
firebase deploy --only firestore:rules
```

## Firebase Security Rules และ Admin Role

โปรเจกต์มี rules ในไฟล์ `firestore.rules` โดยกำหนดว่า:

- บุคคลทั่วไปอ่านสินค้าได้
- ลูกค้าจัดการโปรไฟล์และตะกร้าของตนเองเท่านั้น
- ลูกค้าสร้างออเดอร์ของตนเองและอัปโหลดสลิปตามสถานะที่อนุญาต
- Admin จัดการสินค้า ออเดอร์ และข้อมูลที่จำเป็นได้
- การตรวจสิทธิ์ admin ใช้ field `role` ใน Firestore ไม่ได้ตรวจจากหน้าจอเพียงอย่างเดียว

วิธีตั้ง admin ครั้งแรก:

1. สร้างผู้ใช้ด้วย Firebase Authentication แบบ Email/Password
2. เปิด Firestore และสร้างหรือแก้ document ที่ `users/{uid}`
3. กำหนดข้อมูลอย่างน้อยดังนี้:

```json
{
  "uid": "AUTH_UID_HERE",
  "displayname": "Admin",
  "base64avatar": "",
  "role": "admin"
}
```

การลบสินค้าอนุญาตเฉพาะบัญชี `adminung@abc.com` ตามค่าที่กำหนดใน `AdminRoleService` และ `firestore.rules` หากเปลี่ยนอีเมลต้องแก้ทั้งสองตำแหน่งแล้ว deploy rules ใหม่

## ค่าที่ต้องปรับก่อนนำไปใช้กับร้านอื่น

- พิกัดร้านอยู่ที่ `AppConstant.shopLocation` ใน `lib/core/app_constant.dart`
- รัศมีส่งฟรีอยู่ที่ `CartController.freeDeliveryRadiusMeters` ปัจจุบันเท่ากับ 1,000 เมตร
- QR PromptPay อยู่ที่ `images/promptpay.JPG`
- ชื่อบัญชีและเลขบัญชี PromptPay ยังเขียนไว้ใน UI ของหน้า Order
- อีเมลที่มีสิทธิ์ลบสินค้าอยู่ใน `AdminRoleService` และ `firestore.rules`
- Firebase configuration อยู่ใน `lib/firebase_options.dart` และไฟล์ config ของแต่ละ platform

## ข้อจำกัดและงานที่ควรพัฒนาต่อ

### ข้อมูลและกระบวนการสั่งซื้อ

- ยอดขายวันนี้กรองออเดอร์ที่ `paid` และไม่ `cancelled` แล้ว แต่ยังอิง
  `createdAt` หรือวันที่สร้างออเดอร์ ไม่ใช่วันที่ยืนยันการชำระเงินจริง
  ออเดอร์ที่สร้างเมื่อวานแต่ชำระวันนี้จึงยังถูกนับเป็นยอดของเมื่อวาน
- เมื่อยกเลิกออเดอร์ที่ชำระแล้ว ระบบคืนสต๊อกและเปลี่ยนสถานะออเดอร์ได้
  แต่ยังไม่มีสถานะหรือกระบวนการคืนเงินให้ลูกค้า
- หากสินค้าถูกลบออกจาก collection `product` ก่อนยกเลิกออเดอร์
  ระบบจะไม่ยกเลิกออเดอร์นั้น เพื่อป้องกันการคืนสต๊อกไม่ครบ
  ควรเปลี่ยนจากการลบสินค้าเป็นการ archive หรือปิดขาย
- ข้อมูลเบอร์โทรมาจาก `FirebaseAuth.currentUser.phoneNumber`
  แต่ระบบสมัครสมาชิกใช้ Email/Password จึงอาจไม่มีเบอร์โทรในออเดอร์
- ฟิลด์ `discount` มีอยู่ในข้อมูลออเดอร์ แต่ปัจจุบันกำหนดเป็น `0`
  และยังไม่มีระบบคูปองหรือส่วนลด
- การจัดส่งรองรับเฉพาะรับเองหรือส่งฟรีภายใน 1 กม.
  ยังไม่มีค่าจัดส่งแบบหลายระยะหรือหลายระดับ

### การชำระเงินและไฟล์รูป

- PromptPay เป็น QR รูปภาพและให้ Admin ตรวจสลิปด้วยคน
  ยังไม่มี payment gateway, webhook หรือการตรวจสลิปอัตโนมัติ
- รูปสินค้า Avatar และสลิปเก็บเป็น Base64 ใน Firestore
  จึงติดข้อจำกัดขนาด document และมีต้นทุนการอ่านสูง
  ควรย้ายไฟล์ไป Firebase Storage แล้วเก็บเฉพาะ URL

### บัญชีและการแจ้งเตือน

- การลบบัญชีลบ Firebase Authentication, โปรไฟล์ และตะกร้า
  แต่ยังไม่ลบหรือ anonymize ประวัติออเดอร์ของผู้ใช้
- ยังไม่มี push notification เมื่อมีออเดอร์ใหม่ อัปโหลดสลิป
  หรือมีการเปลี่ยนสถานะออเดอร์

### Dashboard และการจัดการข้อมูล

- Dashboard มีเฉพาะยอดขายวันนี้และเปอร์เซ็นต์เทียบเมื่อวาน
  ยังไม่มีกราฟ รายงานย้อนหลัง หรือตัวเลือกช่วงวันที่
- Admin Web โหลดสินค้าและออเดอร์ทั้งหมดแบบ real-time โดยยังไม่มี pagination
  หรือการจำกัดจำนวนข้อมูล ซึ่งจะอ่านข้อมูลมากขึ้นเมื่อระบบเติบโต
- ช่องค้นหาบน Admin Web ยังเป็นส่วนแสดงผลและไม่ได้กรองข้อมูลจริง
- หมวดหมู่สินค้ายังใช้ค่า `General` ในฝั่ง Admin
  และยังไม่มี field หมวดหมู่ในข้อมูลสินค้าจริง

### คุณภาพและการนำขึ้นระบบ

- ชุดทดสอบปัจจุบันมี 3 รายการ ครอบคลุม Product model
  และการเตรียมจำนวนสินค้าสำหรับคืนสต๊อก
  ควรเพิ่ม unit, widget, integration และ Firestore Rules tests
  สำหรับ transaction, การตัดและคืนสต๊อก, การชำระเงิน และเส้นทางสั่งซื้อ
- เวอร์ชันใน `pubspec.yaml`, Android และ iOS ยังไม่ตรงกัน
  ควรใช้เวอร์ชันจาก `pubspec.yaml` เป็นแหล่งเดียวก่อน release รอบถัดไป
- `image_gallery_saver_plus` ยังไม่รองรับ Swift Package Manager
  และอาจสร้างปัญหากับ Flutter/iOS toolchain รุ่นอนาคต

## ลำดับงานที่แนะนำ

1. เพิ่มสถานะและขั้นตอนคืนเงินสำหรับออเดอร์ที่ชำระแล้วแต่ถูกยกเลิก
2. เปลี่ยนการลบสินค้าเป็น archive เพื่อเก็บความสัมพันธ์กับออเดอร์เก่า
3. ใช้ `paymentVerifiedAt` เป็นวันที่รับรู้ยอดขาย และเพิ่มรายงานตามช่วงวันที่
4. ย้ายรูปสินค้า Avatar และสลิปจาก Base64 ไป Firebase Storage
5. เพิ่ม pagination และระบบค้นหาจริงใน Admin Web
6. เพิ่มช่องเบอร์โทร หมวดหมู่สินค้า ส่วนลด และค่าจัดส่ง
7. เพิ่ม push notification และ payment gateway เมื่อ flow หลักนิ่งแล้ว
8. เพิ่ม integration tests และ Firestore Rules tests สำหรับ flow สั่งซื้อ
   ตรวจสลิป ยกเลิก คืนสต๊อก และคืนเงิน

## ติดต่อผู้พัฒนา

คอร์สสอน Flutter และรับปรึกษาโปรเจกต์ Android, iOS และเว็บไซต์ โดยมาสเตอร์อึ่ง

- Line: <http://line.me/ti/p/XI-Ksj7Jzq>
- Email: <phrombutr@gmail.com>
- Mobile: 081-859-5309
- Website: <https://bit.ly/32yar4n>
- Privacy Policy: <https://www.papayashotgo.com/policy/ungShopPolicy.html>
- Support: <https://www.papayashotgo.com/shopOnlineMasterUng/support.html>
