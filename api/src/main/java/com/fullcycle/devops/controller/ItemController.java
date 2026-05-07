package com.fullcycle.devops.controller;

import com.fullcycle.devops.dto.ItemRequest;
import com.fullcycle.devops.dto.ItemResponse;
import com.fullcycle.devops.service.ItemService;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/items")
@RequiredArgsConstructor
@Slf4j
public class ItemController {

    private final ItemService itemService;
    private final Counter itemCreatedCounter;
    private final Counter itemUpdatedCounter;
    private final Counter itemDeletedCounter;

    public ItemController(ItemService itemService, MeterRegistry meterRegistry) {
        this.itemService = itemService;
        this.itemCreatedCounter = Counter.builder("items.created.total")
                .description("Total number of items created")
                .register(meterRegistry);
        this.itemUpdatedCounter = Counter.builder("items.updated.total")
                .description("Total number of items updated")
                .register(meterRegistry);
        this.itemDeletedCounter = Counter.builder("items.deleted.total")
                .description("Total number of items deleted")
                .register(meterRegistry);
    }

    @GetMapping
    public ResponseEntity<List<ItemResponse>> getAllItems() {
        log.info("GET /api/items - Fetching all items");
        List<ItemResponse> items = itemService.getAllItems();
        return ResponseEntity.ok(items);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ItemResponse> getItemById(@PathVariable String id) {
        log.info("GET /api/items/{} - Fetching item by id", id);
        ItemResponse item = itemService.getItemById(id);
        return ResponseEntity.ok(item);
    }

    @PostMapping
    public ResponseEntity<ItemResponse> createItem(@Valid @RequestBody ItemRequest itemRequest) {
        log.info("POST /api/items - Creating new item: {}", itemRequest.getName());
        ItemResponse createdItem = itemService.createItem(itemRequest);
        itemCreatedCounter.increment();
        return new ResponseEntity<>(createdItem, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ItemResponse> updateItem(
            @PathVariable String id,
            @Valid @RequestBody ItemRequest itemRequest) {
        log.info("PUT /api/items/{} - Updating item", id);
        ItemResponse updatedItem = itemService.updateItem(id, itemRequest);
        itemUpdatedCounter.increment();
        return ResponseEntity.ok(updatedItem);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteItem(@PathVariable String id) {
        log.info("DELETE /api/items/{} - Deleting item", id);
        itemService.deleteItem(id);
        itemDeletedCounter.increment();
        return ResponseEntity.noContent().build();
    }
}
