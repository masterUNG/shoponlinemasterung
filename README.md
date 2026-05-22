
# คอร์ส สอน Flutter ตัวต่อตัว เลือกเจาะ หัวข้อที่ต้องการเรียนได้
### Workshop Project แบบจับมือทำ กับ มาสเตอร์ อึ่ง
## ต้องการรายละเอียดเพิ่ม หรือ ต้องการ ปรึกษาการทำ โปรเจ็คแอนดรอยด์, โปรเจ็ค iOS, โปรเจ็คเว็ปไซด์
### ติดต่อมาสเตอร์ อึ่ง เลย ที่
[![IMG_6065.jpg](https://s26.postimg.cc/kajrs6fbt/IMG_6065.jpg)](https://postimg.cc/image/7j5llo5jp/)
## ติดต่อมาสเตอร์
https://bit.ly/32yar4n

http://line.me/ti/p/XI-Ksj7Jzq

phrombutr@gmail.com

Mobile 0818595309

https://app-privacy-policy-generator.firebaseapp.com/

https://www.papayashotgo.com/policy/ungShopPolicy.html

https://www.papayashotgo.com/shopOnlineMasterUng/support.html

## Firebase Security Rules และ Admin Role

โปรเจกต์นี้ใช้ Firestore role ที่ `users/{uid}.role`

- ลูกค้าทั่วไป: `role` เป็น `customer`
- ผู้ดูแลระบบ: `role` ต้องเป็น `admin`

วิธีตั้ง admin ครั้งแรก:

1. สร้างผู้ใช้ admin ด้วย Firebase Authentication แบบ Email/Password
2. เปิด Firestore แล้วสร้าง/แก้ document ที่ path `users/{uid}` ของบัญชีนั้น
3. ใส่ field ขั้นต่ำ:

```json
{
  "uid": "AUTH_UID_HERE",
  "displayname": "Admin",
  "base64avatar": "",
  "role": "admin"
}
```

Deploy rules:

```sh
firebase deploy --only firestore:rules
```
