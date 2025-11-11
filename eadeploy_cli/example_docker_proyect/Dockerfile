FROM golang:1.25

WORKDIR /app

COPY go.mod ./
RUN go mod download && go mod verify

COPY . .
RUN go build -v -o main .

EXPOSE 3030

CMD ["/app/main"]
