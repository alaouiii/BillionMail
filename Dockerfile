# المرحلة 1: بناء البرنامج (Build Stage)
FROM golang:1.21-alpine AS builder

WORKDIR /app

# تثبيت الأدوات الضرورية للبناء
RUN apk add --no-cache git

# نسخ ملفات الـ Go modules (إلا كانت كاينة فـ الـ Root)
COPY go.mod go.sum ./
RUN go mod download || true

# نسخ كاع الملفات للـ Container
COPY . .

# بناء البرنامج من المسار اللي عطيتيني
# غادي نبنيوه ونسميوه "billionapp"
RUN go build -o billionapp ./BillionMail/core/main.go

# المرحلة 2: التشغيل (Runtime Stage)
FROM alpine:latest
RUN apk add --no-cache ca-certificates libc6-compat
WORKDIR /root/

# نسخ البرنامج اللي بنينا من المرحلة الأولى
COPY --from=builder /app/billionapp .

# نسخ المجلدات الضرورية (BillionMail كيحتاج الـ views والـ public باش يبان)
# إلا كانت هاد المجلدات وسط BillionMail، غادي ننسخوها
COPY --from=builder /app/BillionMail/view ./view 2>/dev/null || true
COPY --from=builder /app/BillionMail/public ./public 2>/dev/null || true

# البورت الافتراضي لـ Go هو 8080 (أو بدلو لـ 3000 إلا كان السكربت كيخدم بيه)
EXPOSE 8080

# تشغيل البرنامج
CMD ["./billionapp"]
