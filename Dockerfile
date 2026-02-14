# المرحلة 1: البناء
FROM golang:1.21-alpine AS builder

# WORKDIR الرئيسي
WORKDIR /app

# تثبيت الأدوات الضرورية
RUN apk add --no-cache git gcc musl-dev

# نسخ كاع الملفات للـ Container
COPY . .

# الانتقال للمجلد اللي فيه go.mod و go.sum والمباشرة بالبناء
WORKDIR /app/BillionMail/core

# تحميل المكتبات وبناء البرنامج (billionapp)
RUN go mod download
RUN go build -o /app/billionapp main.go

# المرحلة 2: التشغيل (تصغير حجم الصورة)
FROM alpine:latest
RUN apk add --no-cache ca-certificates libc6-compat
WORKDIR /app

# نسخ البرنامج اللي بنينا
COPY --from=builder /app/billionapp .

# نسخ المجلدات الضرورية (view و public) باش السكربت يلقى الصفحات
# غادي ننسخوهم للـ Root ديال البرنامج فـ /app
COPY --from=builder /app/BillionMail/view ./view
COPY --from=builder /app/BillionMail/public ./public

# البورت (BillionMail Go غالباً كيخدم بـ 8080)
EXPOSE 8080

# تشغيل البرنامج
CMD ["./billionapp"]
