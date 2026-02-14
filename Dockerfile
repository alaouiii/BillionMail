# المرحلة 1: البناء
FROM golang:1.21-alpine AS builder

WORKDIR /app

# تثبيت git
RUN apk add --no-cache git

# نسخ كل الملفات
COPY . .

# الانتقال إلى مجلد BillionMail حيث يوجد الكود
WORKDIR /app/BillionMail

# تهيئة Go modules
RUN go mod init github.com/alaouiii/BillionMail || true
RUN go mod tidy || true

# بناء البرنامج
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /app/billionapp ./core/main.go

# المرحلة 2: التشغيل
FROM alpine:latest

RUN apk add --no-cache ca-certificates libc6-compat

WORKDIR /root/

# نسخ البرنامج المبني من المرحلة الأولى
COPY --from=builder /app/billionapp .

# نسخ الملفات المطلوبة إن وجدت
COPY --from=builder /app/BillionMail/config ./config 2>/dev/null || true
COPY --from=builder /app/BillionMail/templates ./templates 2>/dev/null || true

# تعريف المنفذ
EXPOSE 8080

# تشغيل البرنامج
CMD ["./billionapp"]
