package com.library.service;

import com.library.dto.BookRequest;
import com.library.exception.BookNotFoundException;
import com.library.model.Book;
import com.library.model.BookStatus;
import com.library.repository.BookRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class BookServiceTest {

    @Mock
    private BookRepository bookRepository;

    @InjectMocks
    private BookService bookService;

    @Test
    void findByIdReturnsBookWhenItExists() {
        Book book = new Book();
        book.setId(1L);
        book.setTitle("Na Drini cuprija");
        book.setAuthor("Ivo Andric");
        when(bookRepository.findById(1L)).thenReturn(Optional.of(book));

        Book result = bookService.findById(1L);

        assertThat(result.getTitle()).isEqualTo("Na Drini cuprija");
    }

    @Test
    void findByIdThrowsWhenBookDoesNotExist() {
        when(bookRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> bookService.findById(99L))
                .isInstanceOf(BookNotFoundException.class)
                .hasMessageContaining("99");
    }

    @Test
    void createDefaultsStatusToAvailable() {
        BookRequest request = new BookRequest("Prokleta avlija", "Ivo Andric", 1954, null);
        when(bookRepository.save(any(Book.class))).thenAnswer(inv -> inv.getArgument(0));

        Book result = bookService.create(request);

        assertThat(result.getStatus()).isEqualTo(BookStatus.DOSTUPNO);
        verify(bookRepository).save(any(Book.class));
    }

    @Test
    void deleteRemovesExistingBook() {
        Book book = new Book();
        book.setId(5L);
        when(bookRepository.findById(5L)).thenReturn(Optional.of(book));

        bookService.delete(5L);

        verify(bookRepository).delete(book);
    }
}
