package dk.statsbiblioteket.mediestream.mockticketservice.authorization;

import javax.xml.bind.annotation.XmlRootElement;
import java.util.ArrayList;

@XmlRootElement
public class UserObjAttributeDTO {
	
	private String attribute;
	private ArrayList<String> values = new  ArrayList<String>();

	public UserObjAttributeDTO(){		
	}
	
	public String getAttribute() {
		return attribute;
	}
	public void setAttribute(String attribute) {
		this.attribute = attribute;
	}
	public ArrayList<String> getValues() {
		return values;
	}
	public void setValues(ArrayList<String> values) {
		this.values = values;
	}
	
}
