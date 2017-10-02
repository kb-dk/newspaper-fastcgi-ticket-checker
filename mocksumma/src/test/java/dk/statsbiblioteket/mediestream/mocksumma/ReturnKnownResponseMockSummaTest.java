package dk.statsbiblioteket.mediestream.mocksumma;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 *
 */
class ReturnKnownResponseMockSummaTest {

    ReturnKnownResponseMockSumma backend;

    @BeforeEach
    public void beforeEach() {
        backend = new ReturnKnownResponseMockSumma();

    }

    @Test
    void request2plus2() {
        assertEquals("4", backend.directJSON("2+2"));
    }

    @Test()
    void requestNull() {
        Assertions.assertThrows(NullPointerException.class, () -> backend.directJSON(null));
    }

    @Test
    void requestUnknown() {
        Assertions.assertThrows(IllegalArgumentException.class, () -> backend.directJSON("2+2+2"));

    }

}
