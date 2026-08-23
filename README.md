# Shop Online Master Ung

แอปซื้อขายสินค้าออนไลน์สำหรับร้านค้าขนาดเล็ก พัฒนาด้วย Flutter และ Firebase
โดยแยกการใช้งานหลักเป็น 2 ฝั่ง:

- **Customer App** สำหรับ Android, iOS, macOS และ Windows ใช้ดูสินค้า ใส่ตะกร้า สั่งซื้อ ชำระเงิน และติดตามออเดอร์
- **Admin Web** สำหรับผู้ดูแลร้าน ใช้จัดการสินค้า สต๊อก ออเดอร์ สลิป และยอดขายเบื้องต้น

> Linux มี runner อยู่ใน repository แต่ยังไม่รองรับการรันจริง เพราะ
> `lib/firebase_options.dart` ยังไม่มี Firebase configuration สำหรับ Linux

ระบบใช้ Firebase Authentication สำหรับบัญชีผู้ใช้ และ Cloud Firestore สำหรับข้อมูลสินค้า ตะกร้า โปรไฟล์ และออเดอร์แบบ real-time

## สถานะโปรเจกต์

อัปเดตจากการวิเคราะห์โค้ดล่าสุด: **23 สิงหาคม 2026**

สถานะโดยรวม: **MVP ใช้งานได้แล้ว** สำหรับ flow ร้านค้าออนไลน์ขนาดเล็ก ตั้งแต่สมัครสมาชิก ดูสินค้า ใส่ตะกร้า สร้างออเดอร์ ตัดสต๊อก ชำระผ่าน PromptPay หรือเงินสด ตรวจสลิป จัดการออเดอร์ และคืนสต๊อกเมื่อยกเลิก

ระบบ Admin Web ที่ระบุไว้ในเอกสารเดิม:

<https://shopinglinemasterung.web.app>

เวอร์ชันที่พบในโปรเจกต์:

| จุดตั้งค่า | Version | Build |
| --- | --- | --- |
| `pubspec.yaml` | `1.0.13` | `13` |
| Android `android/app/build.gradle.kts` | ใช้ค่าจาก Flutter | ใช้ค่าจาก Flutter |
| iOS/macOS | ใช้ค่า Flutter build variable | ใช้ค่า Flutter build variable |

> ตอนนี้ตั้งให้ `pubspec.yaml` เป็นแหล่งหลักของเลขเวอร์ชัน โดยใช้ `version: 1.0.13+13` แล้วให้ Android, iOS และ macOS อ่านค่าจาก Flutter build version เพื่อลดความสับสนตอน release

### ความคืบหน้าล่าสุด

- ขยับเลขเวอร์ชันหลักใน `pubspec.yaml` เป็น `1.0.13+13`
- ผูก action ของ Admin Web Dashboard แล้ว: เมนูลัดเพิ่มสินค้าเปิด dialog จริง
  ส่วนแก้ไขราคา ปรับสต๊อก ดูสินค้าทั้งหมด และดูออเดอร์ทั้งหมดจะเปลี่ยนไปยัง
  section ที่เกี่ยวข้อง
- อัปเดต iOS/macOS CocoaPods lockfile ให้ใช้ `GoogleUtilities 8.1.2`
- ปรับ Android ให้ใช้ `flutter.versionCode` และ `flutter.versionName` จาก Flutter แทนการ hardcode ใน `android/app/build.gradle.kts`
- ปรับ iOS ให้ใช้ `$(FLUTTER_BUILD_NAME)` และ `$(FLUTTER_BUILD_NUMBER)` ใน `ios/Runner/Info.plist`
- macOS ใช้ `$(FLUTTER_BUILD_NAME)` และ `$(FLUTTER_BUILD_NUMBER)` อยู่แล้ว จึงอิงเลขเดียวกับ Flutter
- รัน `flutter analyze` แล้วไม่พบปัญหา และ `flutter test` ผ่านทั้งหมด 6 tests

## สรุปฟีเจอร์ที่มีแล้ว

| หมวด | สถานะ |
| --- | --- |
| สมัครสมาชิก/เข้าสู่ระบบด้วย Email และ Password | มีแล้ว |
| โปรไฟล์ลูกค้า เบอร์โทร Avatar และพิกัด | มีแล้ว |
| Guest reviewer mode | มีแล้ว |
| รายการสินค้า real-time | มีแล้ว |
| หน้ารายละเอียดสินค้า | มีแล้ว |
| รูปสินค้าหลักและแกลเลอรีหลายรูป | มีแล้ว |
| หมวดหมู่สินค้า tag รายละเอียดสั้น รายละเอียดเต็ม และเงื่อนไขสินค้า | มี field และ UI ฝั่ง Admin แล้ว |
| สินค้าแนะนำและสถานะซ่อน/แสดงสินค้า | มี field และ UI ฝั่ง Admin แล้ว |
| ตะกร้าสินค้าแบบ real-time | มีแล้ว |
| ตรวจจำนวนสินค้าไม่ให้เกินสต๊อก | มีแล้ว |
| สร้างออเดอร์และตัดสต๊อกด้วย Firestore transaction | มีแล้ว |
| รับเองที่ร้านหรือส่งฟรีในรัศมี 1 กม. | มีแล้ว |
| PromptPay พร้อมอัปโหลดสลิป | มีแล้ว |
| เงินสดเมื่อรับสินค้าหรือจัดส่ง | มีแล้ว |
| ติดตามสถานะออเดอร์ | มีแล้ว |
| Admin role จาก Firestore | มีแล้ว |
| Dashboard ยอดขายวันนี้ เทียบเมื่อวาน จำนวนออเดอร์เปิด และสินค้าใกล้หมด | มีแล้ว |
| เพิ่ม แก้ไข ลบสินค้า | มีแล้ว |
| ตรวจ/ปฏิเสธสลิป | มีแล้ว |
| ยืนยันรับเงินสด | มีแล้ว |
| ยกเลิกออเดอร์และคืนสต๊อก | มีแล้ว |
| Firestore Security Rules | มีแล้ว |
| Unit tests เบื้องต้น | มี 6 tests |

## ฟีเจอร์ฝั่งลูกค้า

### บัญชีและโปรไฟล์

- สมัครสมาชิกด้วยชื่อ เบอร์โทร รูป Avatar อีเมล และรหัสผ่าน
- เข้าสู่ระบบและออกจากระบบด้วย Firebase Authentication
- สร้างเอกสารผู้ใช้ที่ `users/{uid}` เมื่อสมัครหรือ login หากยังไม่มีข้อมูล
- บันทึก role เริ่มต้นเป็น `customer`
- แก้ไขเบอร์โทรในหน้า Profile
- ขอสิทธิ์ Location และบันทึกพิกัดเป็น `GeoPoint`
- ใช้พิกัดเพื่อคำนวณสิทธิ์ส่งฟรีจากตำแหน่งร้าน
- ลบบัญชีผู้ใช้ พร้อมลบโปรไฟล์และตะกร้า
- Guest reviewer mode สำหรับทดลองดูสินค้าและตะกร้าโดยไม่สร้างข้อมูลจริง

ข้อจำกัดปัจจุบัน:

- การลบบัญชียังไม่ลบหรือ anonymize ประวัติออเดอร์เดิม
- ยังไม่มีระบบที่อยู่จัดส่งแบบละเอียด เช่น บ้านเลขที่ ซอย หมู่บ้าน จุดสังเกต หรือหมายเหตุคนส่ง

### Mall และรายละเอียดสินค้า

- อ่านข้อมูลจาก collection `product` แบบ real-time
- เรียงสินค้าตาม `timestamp` ล่าสุดก่อน
- แสดงเฉพาะสินค้าที่ `isActive == true`
- แสดงชื่อสินค้า รายละเอียด ราคา หน่วย รูป และสต๊อก
- แจ้งสถานะสินค้าใกล้หมดเมื่อเหลือไม่เกิน 5 ชิ้น
- ไม่อนุญาตให้เพิ่มสินค้าที่หมดแล้วลงตะกร้า
- มีหน้า `ProductDetailView` แสดง:
  - แกลเลอรีรูปสินค้า
  - หมวดหมู่
  - badge สินค้าแนะนำ
  - ราคาและหน่วย
  - รายละเอียดเต็ม
  - เงื่อนไขสินค้า
  - tags
  - จำนวนคงเหลือ
  - stepper เลือกจำนวนก่อนเพิ่มลงตะกร้า

ข้อจำกัดปัจจุบัน:

- ยังไม่มี search/filter/sort ฝั่งลูกค้า
- ยังไม่มีหน้าแยกตามหมวดหมู่ สินค้าขายดี หรือสินค้าแนะนำ
- `soldCount` และ `viewCount` มี field แล้ว แต่ยังไม่เห็น flow เพิ่มค่าเมื่อขายหรือเปิดดู
- `relatedProductIds` มี field แล้ว แต่ยังไม่มี UI สินค้าที่เกี่ยวข้อง

### ตะกร้าสินค้า

- เก็บข้อมูลที่ `users/{uid}/cart/{productId}`
- เพิ่มสินค้าใหม่หรือรวมจำนวนกับรายการเดิมด้วย transaction
- จำกัดจำนวนรวมในตะกร้าไม่ให้เกินสต๊อก ณ ตอนเพิ่มสินค้า
- เพิ่ม ลด รีเซ็ตเป็น 1 และลบสินค้าในตะกร้า
- คำนวณยอดรวมและจำนวนสินค้ารวม
- Guest reviewer mode ใช้ตะกร้าจำลองใน memory ไม่เขียน Firestore

ข้อควรระวัง:

- ข้อมูลสินค้าในตะกร้าเป็น snapshot จากตอนเพิ่มสินค้า หากราคาหรือชื่อสินค้าเปลี่ยนหลังจากนั้น ตะกร้าเดิมอาจไม่อัปเดตตามจนกว่าจะเพิ่มใหม่

### การสั่งซื้อและจัดส่ง

- สร้างออเดอร์จากตะกร้าด้วย Firestore transaction
- ตรวจสต๊อกจริงจาก collection `product` อีกครั้งก่อนสั่งซื้อ
- ตัดสต๊อกด้วย `FieldValue.increment(-quantity)`
- ล้างตะกร้าหลังสร้างออเดอร์สำเร็จ
- สร้างเลขออเดอร์รูปแบบ `ORD-YYYYMMDD-XXXXXX`
- บังคับให้มีเบอร์โทรที่ถูกต้องก่อนสร้างออเดอร์
- รองรับ `pickup` รับเองที่ร้าน
- รองรับ `delivery` ส่งฟรีเมื่อพิกัดลูกค้าอยู่ในรัศมี 1,000 เมตรจากร้าน
- บันทึก `deliveryLocation`, `deliveryDistanceMeters` และ `shopLocation` เมื่อเลือกจัดส่ง

ข้อจำกัดปัจจุบัน:

- ยังไม่มีค่าจัดส่งหลายระดับ
- ยังไม่มี address form แบบอ่านง่าย
- ยังไม่มีเวลาเลือกนัดรับ/นัดส่ง
- ยังไม่มีหมายเหตุของลูกค้าต่อออเดอร์ แม้ model จะมี `pickupInfo.note`

### การชำระเงินและติดตามออเดอร์

- เลือกวิธีชำระตอนสร้างออเดอร์:
  - `promptpay`
  - `cash`
- PromptPay ใช้รูป QR จาก `images/promptpay.JPG`
- ลูกค้าอัปโหลดสลิปจาก Gallery ได้เมื่อสถานะเป็น `unpaid` หรือ `rejected`
- เมื่ออัปโหลดสลิป ระบบเปลี่ยน `paymentStatus` เป็น `waiting_verify`
- เงินสดจะไม่แสดงปุ่มอัปโหลดสลิป และรอ Admin ยืนยันรับเงิน
- หน้า Order แยกออเดอร์ที่ยังดำเนินการกับออเดอร์ที่จบหรือยกเลิก
- แสดงสถานะออเดอร์และสถานะชำระเงินแบบ real-time

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

สำหรับเงินสด:

```text
unpaid -> paid
```

โดย Admin เป็นผู้กดยืนยันรับเงินสด และระบบบันทึก `cashCollectedAt`, `cashCollectedBy` และ `paidAt`

## ฟีเจอร์ฝั่ง Admin Web

เมื่อรันบน Web แอปตั้งค่า initial route เป็นหน้า Admin Login โดยอัตโนมัติ

### สิทธิ์ผู้ดูแล

- ตรวจผู้ใช้จาก Firebase Authentication
- ตรวจ role จาก `users/{uid}.role == "admin"`
- หากไม่ใช่ admin จะ sign out และส่งกลับหน้า login admin
- สิทธิ์ลบสินค้าอนุญาตเฉพาะ email `adminung@abc.com`

### Dashboard

- แสดงยอดขายวันนี้
- เปรียบเทียบยอดขายกับเมื่อวาน
- นับจำนวนสินค้า
- นับสินค้า active
- นับสินค้าใกล้หมด
- นับออเดอร์ที่ยังเปิดอยู่
- คำนวณยอดขายจากออเดอร์ที่ `paymentStatus == paid` และไม่ถูกยกเลิก
- ใช้ `paidAt` เป็นหลัก และ fallback ไป `createdAt` สำหรับข้อมูลเก่า

ข้อจำกัดปัจจุบัน:

- ยังไม่มีกราฟ
- ยังไม่มีรายงานตามช่วงวันที่
- ยังไม่มี export รายงาน
- ยังไม่มีแยกยอด PromptPay/เงินสดในรายงาน

### จัดการสินค้า

Admin เพิ่มและแก้ไขสินค้าได้จาก Web UI โดยข้อมูลที่รองรับมี:

- ชื่อสินค้า
- คำอธิบายหลัก
- รายละเอียดสั้น
- รายละเอียดเต็ม
- เงื่อนไขสินค้า
- หมวดหมู่
- tags
- รูปหลัก
- รูปแกลเลอรีสูงสุด 4 รูป
- หน่วยสินค้า
- ราคา
- สต๊อก
- สถานะเปิดขาย/ซ่อน
- สินค้าแนะนำ
- `soldCount`
- `viewCount`
- `relatedProductIds`

ระบบแสดงสถานะสินค้า:

- Active
- Low stock
- Out of stock
- Hidden

ข้อจำกัดปัจจุบัน:

- รูปยังเก็บเป็น Base64 ใน Firestore
- ยังไม่มี archive product แบบจริงจังสำหรับสินค้าที่เคยอยู่ในออเดอร์
- การลบสินค้าจริงอาจทำให้ออเดอร์เก่าบางกรณียกเลิกและคืนสต๊อกไม่ได้ เพราะหา product document ไม่เจอ
- ช่อง search บน Admin Web มี UI แล้ว แต่จากโค้ดยังไม่เห็น state/filter ที่ใช้งานจริง
- ปุ่มบน Dashboard ผูก action แล้ว แต่ปุ่ม Export/จัดการสินค้า/เติมสต๊อก/
  ดูทั้งหมดบางตำแหน่งในหน้า Products, Stock และ Orders ยังไม่ได้ผูก action จริง

### จัดการออเดอร์

- โหลดออเดอร์จาก collection `orders` แบบ real-time
- เรียงออเดอร์ล่าสุดก่อน
- แสดงเลขออเดอร์ ลูกค้า จำนวนสินค้า ยอดรวม สถานะ และ note สรุป
- ดูรายการสินค้าในออเดอร์
- ดูข้อมูลผู้รับ/เบอร์โทร
- ดูข้อมูลรับเองหรือจัดส่ง
- แสดงระยะส่งฟรีและพิกัดจัดส่งเมื่อมีข้อมูล
- เปลี่ยนสถานะตามลำดับที่ระบบอนุญาต
- ห้ามข้ามสถานะผิดลำดับ
- ห้ามปิดออเดอร์เป็น `completed` หากยังไม่ชำระเงิน
- ยกเลิกออเดอร์ด้วย transaction และคืนสต๊อก
- ป้องกันการคืนสต๊อกซ้ำด้วย `stockRestoredAt`

ลำดับสถานะที่ Admin เปลี่ยนได้:

```text
pending   -> accepted | cancelled
accepted  -> preparing | cancelled
preparing -> ready | cancelled
ready     -> completed | cancelled
```

### ตรวจชำระเงิน

- PromptPay:
  - ดูสลิปจาก `paymentSlipBase64`
  - ยืนยันสลิป เปลี่ยน `paymentStatus` เป็น `paid`
  - บันทึก `paymentVerifiedAt` และ `paidAt`
  - ปฏิเสธสลิป เปลี่ยน `paymentStatus` เป็น `rejected`
  - บันทึก `paymentRejectedAt`
- เงินสด:
  - แสดงสถานะรอรับเงินสด
  - Admin ยืนยันรับเงินสดได้เมื่อออเดอร์ยังไม่ปิด
  - บันทึก `cashCollectedAt`, `cashCollectedBy`, `paidAt`

## เทคโนโลยีที่ใช้

- Flutter
- Dart `^3.11.4`
- Material 3
- GetX สำหรับ routing, binding และ state management
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Image Picker
- Geolocator
- Image Gallery Saver Plus
- Firebase Hosting
- flutter_launcher_icons

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
│   ├── mall/                   # รายการสินค้าและรายละเอียดสินค้า
│   ├── cart/                   # ตะกร้าและสร้างออเดอร์
│   ├── order/                  # ประวัติออเดอร์และชำระเงิน
│   ├── profile/                # โปรไฟล์ Location เบอร์โทร และลบบัญชี
│   ├── login_admin_web/        # Login ผู้ดูแล
│   └── main_home_web/          # Dashboard และระบบหลังบ้าน
├── firebase_options.dart
└── main.dart
```

ไฟล์สำคัญ:

| ไฟล์ | หน้าที่ |
| --- | --- |
| `lib/main.dart` | init Firebase และเลือก route เริ่มต้น mobile/web |
| `lib/core/app_constant.dart` | สีหลักและพิกัดร้าน |
| `lib/model/product_model.dart` | โครงสร้างสินค้าและรูปสินค้า |
| `lib/model/order_model.dart` | โครงสร้างออเดอร์ รายการสินค้า และ payment method |
| `lib/services/admin_role_service.dart` | ตรวจสิทธิ์ admin และสิทธิ์ลบสินค้า |
| `lib/services/reviewer_mode_service.dart` | Guest reviewer mode |
| `firestore.rules` | Firestore Security Rules |
| `firebase.json` | Firebase Hosting/Firestore config |

## โครงสร้างข้อมูล Firestore

### `users/{uid}`

```json
{
  "uid": "firebase-auth-uid",
  "displayname": "Customer Name",
  "phone": "0812345678",
  "base64avatar": "BASE64_IMAGE",
  "role": "customer",
  "geopoint": "GeoPoint optional"
}
```

### `users/{uid}/cart/{productId}`

```json
{
  "productId": "product-document-id",
  "name": "Product name",
  "description": "Long description",
  "shortDescription": "Short text",
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
  "description": "Main description",
  "shortDescription": "Short description",
  "detailDescription": "Full product detail",
  "condition": "Product condition or sale condition",
  "category": "General",
  "tags": ["tag1", "tag2"],
  "base64Image": "BASE64_IMAGE",
  "images": [
    {
      "base64Image": "BASE64_IMAGE",
      "alt": "image name",
      "sortOrder": 0
    }
  ],
  "unit": "ชิ้น",
  "price": 100,
  "stock": 10,
  "isActive": true,
  "isRecommended": false,
  "relatedProductIds": [],
  "soldCount": 0,
  "viewCount": 0,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp",
  "timestamp": "Timestamp"
}
```

### `orders/{orderId}`

```json
{
  "orderNo": "ORD-20260711-ABC123",
  "userId": "firebase-auth-uid",
  "userName": "Customer Name",
  "userPhone": "0812345678",
  "orderType": "pickup",
  "items": [
    {
      "productId": "product-document-id",
      "productName": "Product name",
      "description": "Description",
      "shortDescription": "Short description",
      "base64Image": "BASE64_IMAGE",
      "unit": "ชิ้น",
      "price": 100,
      "quantity": 2,
      "total": 200
    }
  ],
  "subtotal": 200,
  "discount": 0,
  "deliveryFee": 0,
  "deliveryDistanceMeters": 500,
  "deliveryLocation": "GeoPoint optional",
  "shopLocation": "GeoPoint optional",
  "grandTotal": 200,
  "status": "pending",
  "paymentMethod": "promptpay",
  "paymentStatus": "unpaid",
  "paymentSlipBase64": "BASE64_IMAGE optional",
  "paymentSlipUploadedAt": "Timestamp optional",
  "paymentVerifiedAt": "Timestamp optional",
  "paymentRejectedAt": "Timestamp optional",
  "cashCollectedAt": "Timestamp optional",
  "cashCollectedBy": "admin uid optional",
  "paidAt": "Timestamp optional",
  "stockRestoredAt": "Timestamp optional",
  "pickupInfo": {
    "pickupName": "Customer Name",
    "pickupPhone": "0812345678",
    "note": ""
  },
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

## Firebase Security Rules

ไฟล์ `firestore.rules` กำหนดสิทธิ์หลักดังนี้:

- ผู้ใช้ทั่วไปอ่านสินค้าได้
- ลูกค้าจัดการ profile ของตัวเองได้เฉพาะ field ที่อนุญาต
- ลูกค้าจัดการ cart ของตัวเองได้
- ลูกค้าสร้าง order ของตัวเองได้เมื่อข้อมูลตรงเงื่อนไข
- ลูกค้าอัปโหลดสลิปได้เฉพาะออเดอร์ของตนเอง และเฉพาะ PromptPay ที่ยังไม่จบ
- Admin อ่าน/เขียนข้อมูลที่จำเป็นของสินค้า ออเดอร์ และผู้ใช้ได้
- Admin เท่านั้นที่ตรวจสลิป ยืนยันเงินสด เปลี่ยนสถานะ และลบออเดอร์ได้
- ลบสินค้าได้เฉพาะ admin ที่มี email `adminung@abc.com`

จุดที่ควรปรับปรุงด้าน security:

- ตอนนี้ signed-in user สามารถ update เฉพาะ field `stock` ของสินค้าให้ลดลงได้ตาม rules เพื่อรองรับการตัดสต๊อกจาก client transaction แต่ในเชิง security ผู้ใช้ที่รู้วิธียิง Firestore โดยตรงอาจลด stock ได้โดยไม่สร้างออเดอร์ ควรย้าย business logic การสร้างออเดอร์และตัดสต๊อกไป Cloud Functions หรือปรับ rules ให้ตรวจความสัมพันธ์กับ order ได้รัดกุมขึ้น
- Logic สำคัญ เช่น ตัดสต๊อก คืนสต๊อก ตรวจชำระเงิน ยังทำจาก client/admin client เป็นหลัก เหมาะกับ MVP แต่ควรย้ายไป server-side เมื่อระบบเริ่มใช้งานจริงมากขึ้น
- ยังไม่มี Firestore Rules tests

วิธีตั้ง admin ครั้งแรก:

1. สร้างผู้ใช้ใน Firebase Authentication ด้วย Email/Password
2. เปิด Firestore แล้วสร้างหรือแก้เอกสาร `users/{uid}`
3. ตั้งค่าอย่างน้อยดังนี้:

```json
{
  "uid": "AUTH_UID_HERE",
  "displayname": "Admin",
  "phone": "0812345678",
  "base64avatar": "",
  "role": "admin"
}
```

หากต้องเปลี่ยนอีเมลผู้มีสิทธิ์ลบสินค้า ให้แก้ทั้ง:

- `lib/services/admin_role_service.dart`
- `firestore.rules`

จากนั้น deploy rules ใหม่

## การตั้งค่าและรันโปรเจกต์

สิ่งที่ต้องมี:

- Flutter SDK ที่รองรับ Dart `^3.11.4`
- Java 17 สำหรับ Android build
- Android SDK 36 (แอปตั้ง `minSdk 24`, `compileSdk 36` และ `targetSdk 36`)
- Firebase project
- Firebase Authentication เปิด Email/Password provider
- Cloud Firestore
- FlutterFire CLI สำหรับสร้าง `firebase_options.dart` เมื่อเปลี่ยน Firebase project
- Firebase CLI สำหรับ deploy Hosting และ Rules

ติดตั้ง dependencies:

```sh
flutter pub get
```

รันแอปลูกค้าบน mobile/desktop:

```sh
flutter run
```

Platform ที่มี Firebase configuration แล้วคือ Android, iOS, macOS, Windows และ
Web ส่วน Linux ต้องรัน FlutterFire CLI เพื่อเพิ่ม configuration ก่อน

รัน Admin Web:

```sh
flutter run -d chrome
```

ตรวจคุณภาพโค้ด:

```sh
flutter analyze
flutter test
```

Build web:

```sh
flutter build web
```

Deploy Firebase Hosting:

```sh
firebase deploy --only hosting
```

Deploy Firestore Rules:

```sh
firebase deploy --only firestore:rules
```

### Android release signing

`android/app/build.gradle.kts` อ่าน signing credential จาก
`android/key.properties` ซึ่งเป็นไฟล์ local และไม่ควร commit:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=/absolute/path/to/upload-keystore.jks
```

จากนั้น build release ด้วย:

```sh
flutter build appbundle
```

### แนวทางพัฒนา

- ใช้ GetX Binding ลงทะเบียน controller/service ของแต่ละ module
- เมื่อเพิ่มหรือเปลี่ยน Firestore field ให้ปรับ model, จุดอ่าน/เขียน,
  `firestore.rules`, ตัวอย่าง schema ใน README และ tests ให้สอดคล้องกัน
- `lib/firebase_options.dart`, platform Firebase config, generated plugin files
  และไฟล์ใน Pods เป็น generated/vendor files ไม่ควรแก้ด้วยมือ
- คู่มือการแก้ repository และ checklist สำหรับ agent อยู่ที่ `AGENTS.md`

## ค่าที่ต้องปรับก่อนใช้กับร้านอื่น

| รายการ | ตำแหน่ง |
| --- | --- |
| พิกัดร้าน | `AppConstant.shopLocation` ใน `lib/core/app_constant.dart` |
| รัศมีส่งฟรี | `CartController.freeDeliveryRadiusMeters` |
| รูป QR PromptPay | `images/promptpay.JPG` |
| ข้อความบัญชี PromptPay ใน UI | หน้า Order ที่แสดง QR/รายละเอียดชำระเงิน |
| ไอคอนแอป | `images/icon.png` และ config `flutter_launcher_icons` |
| Firebase project | `lib/firebase_options.dart` และ config แต่ละ platform |
| Admin delete email | `AdminRoleService` และ `firestore.rules` |
| URL privacy/support | `resource/` และลิงก์ในเอกสาร/หน้าที่เกี่ยวข้อง |

## สิ่งที่ควรเพิ่ม

### Priority สูง

1. **ย้ายรูปไป Firebase Storage**
   - ตอนนี้รูปสินค้า รูป Avatar และสลิปเก็บเป็น Base64 ใน Firestore
   - เสี่ยงชนขนาด document limit และทำให้ read/write แพง
   - ควรเก็บไฟล์ใน Storage แล้วบันทึก URL/path ใน Firestore

2. **ย้าย order transaction สำคัญไป Cloud Functions**
   - ลดความเสี่ยง client แก้ stock โดยตรง
   - ตรวจสิทธิ์และคำนวณยอดจากฝั่ง server
   - ทำให้ rules เข้มขึ้นได้

3. **เพิ่มระบบที่อยู่จัดส่ง**
   - บ้านเลขที่
   - หมู่บ้าน/อาคาร
   - ซอย/ถนน
   - จุดสังเกต
   - หมายเหตุคนส่ง
   - เบอร์โทรสำรอง

4. **เพิ่ม search/filter/sort**
   - ฝั่งลูกค้า: ค้นหาชื่อสินค้า หมวดหมู่ tags ราคา สินค้าแนะนำ
   - ฝั่ง Admin: ค้นหาสินค้าและออเดอร์จริง ไม่ใช่เฉพาะช่อง UI

5. **เพิ่ม notification**
   - แจ้งร้านเมื่อมีออเดอร์ใหม่
   - แจ้งร้านเมื่อลูกค้าอัปโหลดสลิป
   - แจ้งลูกค้าเมื่อร้านรับออเดอร์ ตรวจสลิป พร้อมรับสินค้า หรือยกเลิก
   - อาจเริ่มจาก Firebase Cloud Messaging หรือ LINE Notify/LINE Messaging API

### Priority กลาง

6. **รายงานยอดขาย**
   - เลือกช่วงวันที่
   - กราฟรายวัน/รายเดือน
   - แยก PromptPay/เงินสด
   - สินค้าขายดี
   - ลูกค้าซื้อซ้ำ
   - export CSV/Excel

7. **ระบบคืนเงิน**
   - ตอนนี้ยกเลิกออเดอร์ที่ชำระแล้วและคืนสต๊อกได้ แต่ยังไม่มีสถานะ refund
   - ควรเพิ่ม `refundStatus`, `refundedAt`, `refundNote`, `refundBy`

8. **Archive product แทน delete**
   - ลดปัญหาออเดอร์เก่าอ้างอิงสินค้าไม่ได้
   - ใช้ `isActive = false` หรือเพิ่ม `archivedAt`

9. **คูปอง ส่วนลด และโปรโมชัน**
   - มี field `discount` แล้วแต่ยังไม่มี flow ใช้งานจริง
   - เพิ่ม coupon collection, validation, usage limit และวันหมดอายุ

10. **Payment gateway หรือตรวจสลิปอัตโนมัติ**
    - PromptPay ปัจจุบันเป็น manual upload/review
    - ถ้า order เยอะควรต่อ gateway/webhook หรือ slip verification service

### Priority ต่ำถึงกลาง

11. **สินค้าเกี่ยวข้องและ recommended section**
    - ใช้ `relatedProductIds`, `isRecommended`, `soldCount`, `viewCount` ที่มีอยู่ให้เกิดผลใน UI

12. **Pagination / limit query**
    - Admin Web ตอนนี้โหลดสินค้าและออเดอร์ทั้งหมดแบบ real-time
    - เมื่อข้อมูลเยอะควรใช้ pagination, date filter หรือ query limit

13. **เพิ่ม test coverage**
    - Unit test สำหรับ controller logic
    - Widget test สำหรับ flow สำคัญ
    - Integration test สำหรับสั่งซื้อและชำระเงิน
    - Firestore Rules test
    - Transaction test สำหรับตัดสต๊อก/คืนสต๊อก

14. **ปรับ release process ให้ชัดเจนขึ้น**
    - ใช้ `pubspec.yaml` เป็น single source of truth สำหรับเลข version แล้ว
    - เพิ่ม checklist ก่อน release
    - แยก environment dev/staging/prod

## ข้อจำกัดสำคัญที่พบจากโค้ด

- เก็บรูปเป็น Base64 ใน Firestore ทำให้ข้อมูลหนักและเสี่ยงเกินขนาด document
- Business logic สำคัญยังอยู่ฝั่ง client
- ยังไม่มี push notification
- ยังไม่มี payment automation
- ยังไม่มีระบบ refund
- ยังไม่มี address form แบบละเอียด
- ยังไม่มี search/filter ที่ใช้งานครบทั้งลูกค้าและ Admin
- ยังไม่มี pagination สำหรับข้อมูลจำนวนมาก
- ยังไม่มี analytics/report เชิงลึก
- ยังไม่มี Firestore Rules tests
- ปุ่มบน Admin Web Dashboard ผูก action แล้ว แต่หน้า Products, Stock และ Orders
  ยังมีปุ่มบางจุดที่ไม่ได้ผูก action จริง
- version หลักถูกปรับให้ใช้จาก `pubspec.yaml` แล้ว แต่ควรตรวจซ้ำก่อน release ทุกครั้ง

## ผลทดสอบในโปรเจกต์

ชุดทดสอบปัจจุบันอยู่ที่ `test/widget_test.dart` มี 6 tests ครอบคลุม:

- map ข้อมูล `ProductModel`
- decode รูปจาก Base64
- map เบอร์โทรใน `AppUserModel`
- รวมจำนวนสินค้าเพื่อคืนสต๊อก
- reject order item ที่คืนสต๊อกไม่ได้
- backward compatibility ของ PromptPay order เก่า
- audit fields ของการชำระเงินสด

คำสั่งที่ควรรันก่อน release:

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Roadmap แนะนำ

1. เพิ่ม search/filter ใน Mall และ Admin Web
2. เพิ่ม address form และ note สำหรับจัดส่ง
3. เปลี่ยน product delete เป็น archive
4. เพิ่ม refund status สำหรับออเดอร์ที่ชำระแล้วแต่ถูกยกเลิก
5. ย้ายรูปทั้งหมดไป Firebase Storage
6. ย้าย flow สร้างออเดอร์/ตัดสต๊อก/คืนสต๊อกไป Cloud Functions
7. เพิ่ม notification สำหรับออเดอร์และการชำระเงิน
8. เพิ่มรายงานยอดขายตามช่วงวันที่และ export
9. เพิ่ม Firestore Rules tests และ integration tests

## ติดต่อผู้พัฒนา

คอร์สสอน Flutter และรับปรึกษาโปรเจกต์ Android, iOS และเว็บไซต์ โดยมาสเตอร์อึ่ง

- Line: <http://line.me/ti/p/XI-Ksj7Jzq>
- Email: <phrombutr@gmail.com>
- Mobile: 081-859-5309
- Website: <https://bit.ly/32yar4n>
- Privacy Policy: <https://www.papayashotgo.com/policy/ungShopPolicy.html>
- Support: <https://www.papayashotgo.com/shopOnlineMasterUng/support.html>
