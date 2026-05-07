package com.fullcycle.devops.service;

import com.fullcycle.devops.dto.ItemRequest;
import com.fullcycle.devops.dto.ItemResponse;
import com.fullcycle.devops.exception.ResourceNotFoundException;
import com.fullcycle.devops.model.Item;
import com.fullcycle.devops.repository.ItemRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ItemService {

    private final ItemRepository itemRepository;

    public List<ItemResponse> getAllItems() {
        log.info("Fetching all items");
        List<Item> items = itemRepository.findAll();
        log.info("Found {} items", items.size());
        return items.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public ItemResponse getItemById(String id) {
        log.info("Fetching item with id: {}", id);
        Item item = itemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Item not found with id: " + id));
        log.info("Found item: {}", item.getName());
        return mapToResponse(item);
    }

    public ItemResponse createItem(ItemRequest itemRequest) {
        log.info("Creating new item with name: {}", itemRequest.getName());
        
        if (itemRepository.findByName(itemRequest.getName()).isPresent()) {
            throw new IllegalArgumentException("Item with name '" + itemRequest.getName() + "' already exists");
        }
        
        Item item = new Item(itemRequest.getName(), itemRequest.getDescription());
        Item savedItem = itemRepository.save(item);
        log.info("Created item with id: {}", savedItem.getId());
        return mapToResponse(savedItem);
    }

    public ItemResponse updateItem(String id, ItemRequest itemRequest) {
        log.info("Updating item with id: {}", id);
        
        Item existingItem = itemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Item not found with id: " + id));
        
        existingItem.setName(itemRequest.getName());
        existingItem.setDescription(itemRequest.getDescription());
        existingItem.preUpdate();
        
        Item updatedItem = itemRepository.save(existingItem);
        log.info("Updated item: {}", updatedItem.getName());
        return mapToResponse(updatedItem);
    }

    public void deleteItem(String id) {
        log.info("Deleting item with id: {}", id);
        
        if (!itemRepository.existsById(id)) {
            throw new ResourceNotFoundException("Item not found with id: " + id);
        }
        
        itemRepository.deleteById(id);
        log.info("Deleted item with id: {}", id);
    }

    private ItemResponse mapToResponse(Item item) {
        return new ItemResponse(
                item.getId(),
                item.getName(),
                item.getDescription(),
                item.getCreatedAt(),
                item.getUpdatedAt()
        );
    }
}
