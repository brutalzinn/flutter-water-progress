package main

import (
	"log"
	"time"

	"github.com/go-co-op/gocron"
	"github.com/gofiber/fiber"
	"github.com/gofiber/websocket"
)

type TYPE int

const (
	REQUEST_BALANCE TYPE = 1
	WEIGHT_RESPONSE TYPE = 2
)

type GoWebsocketTesterResponse struct {
	Type  TYPE    `json:"type"`
	Value float64 `json:"value"`
}

func main() {
	counterMax := 100.0
	app := fiber.New()
	s := gocron.NewScheduler(time.Local)
	///every five seconds, we increment it.
	cron := "*/5 * * * * *"
	counter := 0.0
	s.CronWithSeconds(cron).Do(func() {
		if counter >= counterMax {
			counter = 0
		}
		counter = counter + 10
	})
	s.StartAsync()
	app.Get("/", websocket.New(func(c *websocket.Conn) {
		log.Printf("client connected %s", c.RemoteAddr())
		for {
			c.WriteJSON(GoWebsocketTesterResponse{Value: counter, Type: WEIGHT_RESPONSE})
			time.Sleep(time.Duration(1) * time.Second)
		}
	}))

	/// we just need a post route at esp 8266 web server to start the balance process.
	app.Post("/balance", func(c *fiber.Ctx) {
		log.Printf("balance request by %s", c.IP())
		///to balance the sensor, we need to inform a absolute weight of a object to get the first referencial.
		//This will be done only one time. But its important that these flux will be executed and the user needs execute it by the app:
		// object with fixed weight at the table --> a request balance its made --> the sensor will be balanced now.
		//TODO: The user is always me. And if we i will notified everytime i dont fill the cup or i am critical focused.. i will need some audio incentive the moviment.
		//the life hack its we can uses the sensorial disorder to do the moviment we need without losing or medical care assistant.
		//https://www.usinainfo.com.br/blog/balanca-arduino-com-celula-de-peso-e-hx711-tutorial-calibrando-e-verificando-peso/

	})
	app.Get("/ping", func(c *fiber.Ctx) {
		log.Printf("handshake accepted by %s", c.IP())
		c.SendString("pong")
	})
	log.Fatal(app.Listen(":80"))
}
