def map_answers_to_clips(answers):
    """Map the GUI answers to CLIPS fact slots"""
    
    # Map budget range to numeric values
    budget_map = {
        "Below ₱5,000": 2500,
        "₱5,000 – ₱10,000": 7500,
        "₱10,001 – ₱20,000": 15000,
        "Above ₱20,000": 25000
    }
    
    # Map experience to CLIPS format
    experience_map = {
        "Yes — it strongly affects approval, experienced adopters are prioritized": "yes",
        "Yes — but it only helps us recommend suitable pets": "yes",
        "No — past experience is not a major factor": "no",
        "Sometimes — only for high-maintenance pets like dogs": "sometimes"
    }
    
    # Map home type to CLIPS format
    home_type_map = {
        "Yes — it determines if the environment suits the pet's needs": "house",
        "Yes — but only for large pets": "yard",
        "No — as long as the adopter is responsible": "apartment",
        "Sometimes — depending on the pet's behavior or size": "apartment"
    }
    
    # Map available space
    space_map = {
        "Small — limited indoor space, suitable for cats or small pets": "small",
        "Medium — small house with enough room for movement": "medium",
        "Large — spacious house or yard for active pets like dogs": "large"
    }
    
    # Map pet type
    pet_map = {
        "Dogs — need more space and time": "dog",
        "Cats — suitable for small homes or apartments": "cat",
        "Rabbits — need moderate space and care": "rabbit",
        "Others (birds, hamsters, etc.) — minimal space required": "other"
    }
    
    # Map children/pets
    children_map = {
        "Yes — it's a major factor; some pets don't get along with kids or other animals": "yes",
        "Yes — but only for aggressive or large pets": "sometimes",
        "No — we assume the adopter will adjust": "no",
        "Sometimes — depends on the pet's temperament": "sometimes"
    }
    
    # Map monthly budget based on affordability
    monthly_budget_map = {
        "Ask their estimated monthly budget": 5000,
        "Review income or employment status": 4000,
        "Ask lifestyle-related questions (shopping, travel habits, etc.)": 3000,
        "We don't formally check — we trust the adopter's honesty": 2000
    }
    
    # Map alone hours to numeric
    hours_map = {
        "0–4 hours — ideal": 2,
        "5–8 hours — acceptable for independent pets": 6,
        "9–12 hours — only for certain types (e.g., cats)": 10,
        "More than 12 hours — not recommended": 14
    }
    
    # Check for disqualifiers
    has_disqualifiers = answers.get('disqualifiers', '') != "None of the above"
    
    # Create the CLIPS fact
    fact = {
        'AdoptionBudget': budget_map.get(answers.get('budget_range', ''), 0),
        'HasPetExperience': 'TRUE' if experience_map.get(answers.get('experience', ''), 'no') in ['yes', 'sometimes'] else 'FALSE',
        'HomeType': home_type_map.get(answers.get('home_type', ''), 'apartment'),
        'AvailableSpace': space_map.get(answers.get('available_space', ''), 'medium'),
        'PreferredPetType': pet_map.get(answers.get('pet_type', ''), 'cat'),
        'HasChildrenOrOtherPets': 'TRUE' if children_map.get(answers.get('children_pets', ''), 'no') in ['yes', 'sometimes'] else 'FALSE',
        'MonthlyPetBudget': monthly_budget_map.get(answers.get('affordability', ''), 3000),
        'AloneHours': hours_map.get(answers.get('alone_hours', ''), 8),
        'AdopterHistoryGood': 'TRUE' if not has_disqualifiers else 'FALSE'
    }
    
    return fact