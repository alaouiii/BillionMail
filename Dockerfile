FROM golang:1.21-alpine

# تثبيت الأدوات الأساسية
RUN apk add --no-cache git gcc musl-dev

WORKDIR /app

# نسخ كاع الملفات
COPY . .

# هاد السطر كيعاوننا نعرفو فين كاين الملف (غادي يبان ليك فـ Logs)
RUN find . -name "go.mod"

# غادي نحاولوا نبنيو البرنامج بـ Force 
# غادي ندخلو للمكان اللي فيه main.go ونبنيوه
RUN cd BillionMail/core && go build -o /app/billionapp main.go || \
    cd core && go build -o /app/billionapp main.go || \
    go build -o /app/billionapp main.go

# المرحلة 2: التشغيل
FROM alpine:latest
RUN apk add --no-cache ca-certificates libc6-compat
WORKDIR /app

# نسخ البرنامج
COPY --from=0 /app/billionapp .

# نسخ المجلدات الضرورية (مع تجاوز الخطأ إلا مالقاهومش)
COPY --from=0 /app/BillionMail/view ./view 2>/dev/null || COPY --from=0 /app/view ./view 2>/dev/null || true
COPY --from=0 /app/BillionMail/public ./public 2>/dev/null || COPY --from=0 /app/public ./public 2>/dev/null || true

# البورت (خلينا فـ 8080 دابا)
EXPOSE 8080

CMD ["./billionapp"]
