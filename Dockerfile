# المرحلة 1: بناء البرنامج
FROM golang:1.21-alpine AS builder

WORKDIR /app

# تثبيت git
RUN apk add --no-cache git

# نسخ ملفات الموديول بطريقة مرنة
# استعملنا النجمة * باش ينسخ go.mod و go.sum إلا كان موجود، وبلا ما يفشل إلا مالقاش go.sum
COPY go.mod* go.sum* ./

# تحميل المكتبات (إلا فشل ماشي مشكل غيدوز للخطوة الجاية)
RUN go mod download || true

# نسخ كاع الكود
COPY . .

# بناء البرنامج
# تأكدنا من المسار اللي عطيتيني BillionMail/core/main.go
RUN go build -o billionapp ./BillionMail/core/main.go

# المرحلة 2: التشغيل
FROM alpine:latest
RUN apk add --no-cache ca-certificates libc6-compat
WORKDIR /root/

# نسخ البرنامج
COPY --from=builder /app/billionapp .

# نسخ مجلدات العرض (إلا كانت موجودة)
COPY --from=builder /app/BillionMail/view ./view 2>/dev/null || true
COPY --from=builder /app/BillionMail/public ./public 2>/dev/null || true

# البورت
EXPOSE 8080

CMD ["./billionapp"]
