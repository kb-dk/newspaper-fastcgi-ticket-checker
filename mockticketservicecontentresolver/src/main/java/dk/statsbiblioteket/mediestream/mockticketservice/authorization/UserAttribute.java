package dk.statsbiblioteket.mediestream.mockticketservice.authorization;


import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;
import java.util.List;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(propOrder = {
        "name",
        "values"
})
public class UserAttribute {
    @XmlElement(name = "attribute", required = true)
    private String name;

    @XmlElement(name = "values")
    private List<String> values;

    public UserAttribute() {
    }

    public UserAttribute(String name, List<String> values) {
        this.name = name;
        this.values = values;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<String> getValues() {
        return values;
    }

    public void setValues(List<String> values) {
        this.values = values;
    }
}
