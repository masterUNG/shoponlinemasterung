# Shop Online Master Ung

แอปซื้อขายสินค้าออนไลน์สำหรับร้านค้าขนาดเล็ก พัฒนาด้วย Flutter โดยแยกการใช้งานเป็น 2 ส่วน:

- แอปลูกค้าบน Android/iOS สำหรับดูสินค้า สั่งซื้อ ชำระเงิน และติดตามออเดอร์
- ระบบผู้ดูแลบน Flutter Web สำหรับจัดการสินค้า สต๊อก ออเดอร์ และตรวจสลิป

ข้อมูลหลักทำงานแบบ real-time ผ่าน Firebase Authentication และ Cloud Firestore

## สถานะโปรเจกต์ปัจจุบัน

ระบบหลักที่มีอยู่ในโค้ด:

| ส่วนงาน | สถานะ |
| --- | --- |
| สมัครสมาชิกและเข้าสู่ระบบด้วย Email/Password | ใช้งานแล้ว |
| Guest reviewer mode | ใช้งานแล้ว |
| แสดงสินค้าแบบ real-time | ใช้งานแล้ว |
| ตะกร้าสินค้าและตรวจจำนวนสต๊อก | ใช้งานแล้ว |
| สร้างออเดอร์และตัดสต๊อกด้วย Firestore transaction | ใช้งานแล้ว |
| รับสินค้าเองหรือส่งฟรีในรัศมี 1 กม. | ใช้งานแล้ว |
| ชำระผ่าน QR PromptPay และอัปโหลดสลิป | ใช้งานแล้ว |
| ติดตามสถานะออเดอร์ | ใช้งานแล้ว |
| Admin Web และระบบ role | ใช้งานแล้ว |
| เพิ่ม แก้ไข และลบสินค้า | ใช้งานแล้ว |
| ตรวจหรือปฏิเสธสลิป | ใช้งานแล้ว |
| Dashboard ยอดขายรายวันและสถิติย้อนหลัง | ยังไม่สมบูรณ์ |
| Payment gateway อัตโนมัติ | ยังไม่มี |
| Push notification | ยังไม่มี |

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
- Dashboard แสดงยอดรวมออเดอร์ จำนวนออเดอร์เปิด สินค้าทั้งหมด และสินค้าใกล้หมด
- ดูสินค้าและออเดอร์จาก Firestore แบบ real-time
- เพิ่มสินค้าใหม่พร้อมรูป ชื่อ รายละเอียด ราคา หน่วย และสต๊อก
- แก้ไขข้อมูลสินค้า ราคา รูป และสต๊อก
- แสดงสินค้า Active, Low stock และ Out of stock
- ดูรายละเอียดออเดอร์ รายการสินค้า ข้อมูลผู้รับ และพิกัดจัดส่ง
- เปลี่ยนสถานะออเดอร์ตามลำดับงาน
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

- Dashboard ใช้ยอดรวมของออเดอร์ทั้งหมด แม้ป้ายกำกับจะแสดงว่าเป็นยอดขายวันนี้
- ข้อความเปรียบเทียบ `+18% จากเมื่อวาน` เป็นข้อความคงที่ ยังไม่ได้คำนวณจากข้อมูลจริง
- ระบบ PromptPay เป็น QR แบบรูปภาพและตรวจสลิปด้วยคน ยังไม่มี payment gateway หรือ webhook
- รูปสินค้า Avatar และสลิปเก็บเป็น Base64 ใน Firestore จึงมีข้อจำกัดขนาด document และต้นทุนการอ่าน ควรย้ายไป Firebase Storage
- ยังไม่มีระบบค้นหา หมวดหมู่สินค้า คูปอง ส่วนลด ภาษี หรือค่าจัดส่งแบบหลายระดับ
- ยังไม่มี push notification เมื่อลูกค้าหรือร้านเปลี่ยนสถานะ
- การลบบัญชีลบโปรไฟล์และตะกร้า แต่ไม่ลบหรือทำ anonymize ประวัติออเดอร์
- ข้อมูลเบอร์โทรมาจาก `FirebaseAuth.currentUser.phoneNumber` แต่ระบบสมัครสมาชิกปัจจุบันใช้ Email/Password จึงอาจเป็นค่าว่าง
- สต๊อกถูกตัดทันทีเมื่อสร้างออเดอร์ แต่การยกเลิกออเดอร์ยังไม่คืนสต๊อกอัตโนมัติ
- ควรเพิ่ม unit test, widget test และ integration test สำหรับ transaction, rules และเส้นทางสั่งซื้อ

## ติดต่อผู้พัฒนา

คอร์สสอน Flutter และรับปรึกษาโปรเจกต์ Android, iOS และเว็บไซต์ โดยมาสเตอร์อึ่ง

- Line: <http://line.me/ti/p/XI-Ksj7Jzq>
- Email: <phrombutr@gmail.com>
- Mobile: 081-859-5309
- Website: <https://bit.ly/32yar4n>
- Privacy Policy: <https://www.papayashotgo.com/policy/ungShopPolicy.html>
- Support: <https://www.papayashotgo.com/shopOnlineMasterUng/support.html>
