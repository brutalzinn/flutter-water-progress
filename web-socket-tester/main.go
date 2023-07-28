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

type GoWebSocketTesterRequest struct {
	Cron string `json:"cron"`
}
type GoWebsocketTesterResponse struct {
	Type  string `json:"type"`
	Value int    `json:"value"`
}

func main() {
	//really like express. i like it.
	counterMax := 100
	app := fiber.New()
	app.Get("/ws", websocket.New(func(c *websocket.Conn) {
		//lets start a new goroutine that can send a random increment message to the flutter app and we can plot the gauge.
		for {
			s := gocron.NewScheduler(time.UTC)
			var GoWebSocketTesterRequest GoWebSocketTesterRequest
			err := c.ReadJSON(&GoWebSocketTesterRequest)
			if err != nil {
				break
			}
			log.Printf("Received: %s", GoWebSocketTesterRequest)
			counter := 0
			s.CronWithSeconds(GoWebSocketTesterRequest.Cron).Do(func() {
				c.WriteJSON(GoWebsocketTesterResponse{Value: counter, Type: "weight"})
				counter++
				log.Println("Running %s", time.Now())
			})
			c.WriteJSON(GoWebSocketTesterRequest)
			if err != nil {
				break
			}
			if counter >= counterMax {
				counter = 0
			}
			s.StartBlocking()
		}

	}))

	log.Fatal(app.Listen(":3000"))
}
