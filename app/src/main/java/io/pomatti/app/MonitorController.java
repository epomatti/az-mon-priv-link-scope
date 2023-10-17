package io.pomatti.app;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MonitorController {

	@GetMapping("/monitor")
	public void index() {
		System.out.println("Writing to log");
	}

}
