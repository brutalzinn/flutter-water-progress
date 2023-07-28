package websockettester

import (
	"log"

	"github.com/gofiber/fiber"
)

/*
[BLOG.ROBERTOCPAES.DEV - HYPERFOCUS - PERSONAL DATA COMMENTARY - IGNORE]
  Lets do some go horse power and use fiber as web socket server while i am waiting my new weight modules.
[BLOG.ROBERTOCPAES.DEV - HYPERFOCUS - PERSONAL DATA COMMENTARY - IGNORE]
*/

func main() {
	//really like express. i like it.

	app := fiber.New()

	app.Get("/ws", websocket.New(func(c *websocket.Conn) {
		// Websocket logic
		for {
			mtype, msg, err := c.ReadMessage()
			if err != nil {
				break
			}
			log.Printf("Read: %s", msg)

			err = c.WriteMessage(mtype, msg)
			if err != nil {
				break
			}
		}
		log.Println("Error:", err)
	}))

	log.Fatal(app.Listen(":3000"))
}
