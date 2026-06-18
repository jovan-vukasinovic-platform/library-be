package com.library.dto;

import com.library.model.BookStatus;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record BookRequest(
        @NotBlank(message = "Title is required")
        @Size(max = 255)
        String title,

        @NotBlank(message = "Author is required")
        @Size(max = 255)
        String author,

        @Min(value = 1000, message = "Published year must be 1000 or later")
        @Max(value = 2100, message = "Published year must be 2100 or earlier")
        Integer publishedYear,

        BookStatus status
) {
}
