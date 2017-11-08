package dk.statsbiblioteket.mediestream.mockticketservice.authorization;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import java.util.List;

@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ticket", propOrder = {
        "userAttributes",
        "resources",
        "type"
})
@XmlRootElement(name = "checkAccessForIdsInputDTO")
public class AuthorizationRequest {
    @XmlElement(name = "ids", required = true)
    private List<String> resources;

    @XmlElement(name = "presentationType", required = true)
    private String type;

    @XmlElement(name = "attributes", required = true)
    private List<UserAttribute> userAttributes;

    public AuthorizationRequest() {
    }

    public AuthorizationRequest(List<String> resources, String type, List<UserAttribute> userAttributes) {
        this.resources = resources;
        this.type = type;
        this.userAttributes = userAttributes;
    }

    public List<String> getResources() {
        return resources;
    }

    public void setResources(List<String> resources) {
        this.resources = resources;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public List<UserAttribute> getUserAttributes() {
        return userAttributes;
    }

    public void setUserAttributes(List<UserAttribute> userAttributes) {
        this.userAttributes = userAttributes;
    }
}
