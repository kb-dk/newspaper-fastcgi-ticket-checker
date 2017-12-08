package dk.statsbiblioteket.mediestream.mockticketservice.authorization;

import javax.xml.bind.annotation.XmlRootElement;
import java.util.ArrayList;

@XmlRootElement
public class CheckAccessForIdsOutputDTO {

	ArrayList<String> accessIds = new ArrayList<String>(); 
    String presentationType;
	String query;
    
    public CheckAccessForIdsOutputDTO(){    	
    }

	public ArrayList<String> getAccessIds() {
		return accessIds;
	}

	public void setAccessIds(ArrayList<String> accessIds) {
		this.accessIds = accessIds;
	}

	public String getQuery() {
		return query;
	}

	public void setQuery(String query) {
		this.query = query;
	}

	public String getPresentationType() {
		return presentationType;
	}

	public void setPresentationType(String presentationType) {
		this.presentationType = presentationType;
	}
	
}
