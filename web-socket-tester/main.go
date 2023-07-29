package main

import (
	"log"
	"time"

	"github.com/go-co-op/gocron"
	"github.com/gofiber/fiber"
	"github.com/gofiber/websocket"
)

/*
[BLOG.ROBERTOCPAES.DEV - HYPERFOCUS - PERSONAL DATA COMMENTARY - IGNORE]

	Lets do some go horse power and use fiber as web socket server while i am waiting my new weight modules.

[BLOG.ROBERTOCPAES.DEV - HYPERFOCUS - PERSONAL DATA COMMENTARY - IGNORE]
*/
type GoWebsocketTesterResponse struct {
	Type  string `json:"type"`
	Value int    `json:"value"`
}

func main() {
	counterMax := 100
	app := fiber.New()
	s := gocron.NewScheduler(time.Local)
	cron := "*/5 * * * * *"
	counter := 0
	s.CronWithSeconds(cron).Do(func() {
		if counter >= counterMax {
			counter = 0
		}
		counter++
	})
	s.StartAsync()
	app.Get("/", websocket.New(func(c *websocket.Conn) {
		log.Printf("client connected %s", c.RemoteAddr())
		for {
			c.WriteJSON(GoWebsocketTesterResponse{Value: counter, Type: "weight"})
			time.Sleep(time.Duration(1) * time.Second)
		}
	}))
	log.Fatal(app.Listen(":80"))
}
