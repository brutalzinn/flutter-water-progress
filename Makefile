test:
	cd web-socket-tester; echo "change dir to web socket tester folder"; \
	docker-compose up -d

stop:
	cd web-socket-tester; echo "change dir to web socket tester folder"; \
	docker-compose down