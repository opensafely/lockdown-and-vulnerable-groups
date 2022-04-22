from cohortextractor import StudyDefinition, patients, Measure

from codelists import *

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
    },
# include all patients registered with a GP at start of analysis period
    index_date="2019-09-01",

    population=patients.satisfying(
        """registered""",
        #registered=patients.registered_as_of("2019-09-01"), #fixed population
        registered=patients.registered_as_of("index_date"), #dynamic population
    ),

    age=patients.age_as_of(
    "index_date",
    return_expectations={
        "rate" : "universal",
        "int" : {"distribution" : "population_ages"}
        }
    ),

    msoa=patients.registered_practice_as_of(
        "index_date",
        returning="msoa",
        return_expectations={
            "category": {"ratios": {"msoa1": 0.1, 
                                    "msoa2": 0.2, 
                                    "msoa3": 0.2,
                                    "msoa4": 0.1, 
                                    "msoa5": 0.2, 
                                    "msoa6": 0.2}},
            "incidence": 1,
        },
    ),

    sex=patients.sex(
    return_expectations={
        "rate": "universal",
        "category": {"ratios": {"M": 0.49, "F": 0.51}},
        # note the real data will also return "U" and "I" but in very small numbers - may wish to exclude them here or later
        }
    ),

    ##Define Vulnerable groups using a six-month loockback period
    
    # 1. patients with intellectual disability
    intdis=patients.with_these_clinical_events(
        intdis_codes,
        between=["index_date - 183 days", "index_date"], #dynamic cohort definition with moving window
        # dates need to be in chronological order here i.e. earliest first 
        returning="binary_flag",
        return_expectations={
        "incidence": 0.05,
        },
    ),

    # 2. children with safeguarding concerns
    safeguard=patients.categorised_as(
        # if you just need a binary flag here, can use `satisying` instead (may run slightly more efficiently)
        {
            "1": "RCGP_safeguard = 1 AND age < 18",
            "0": "DEFAULT",
        },
        RCGP_safeguard=patients.with_these_clinical_events(
            RCGPsafeguard_codes,
            between=["index_date - 183 days", "index_date"],
            # dates need to be in chronological order here i.e. earliest first 
            returning="binary_flag",
        ),
        return_expectations={
            "category":{"ratios": {"0": 0.95, "1": 0.05}}
        },
    ),

    # 3. Domestic violence and abuse
    dva=patients.with_these_clinical_events(
        dva_codes,
        between=["index_date - 183 days", "index_date"],
        # dates need to be in chronological order here i.e. earliest first 
        returning="binary_flag",
        return_expectations={
        "incidence": 0.05,
        },
    ),
    
    
    ## Outcomes (it's useful to use subheadings to separate types of variable)
    
    #count of GP-patient interactions for all patients (vulnerable or not) => main study outcome
    consultations=patients.with_gp_consultations(
        between=["index_date", "index_date + 6 days"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "poisson", "mean": 0.2},
            "incidence": 1.0,
        },
    ),
)

#Generate weekly aggregated datasets for each vulnerable group
measures = [
    Measure(
        id="intdis_rate",
        numerator="consultations",
        denominator="population",
        group_by=["intdis", "msoa"],
    ),

    Measure(
        id="safeguard_rate",
        numerator="consultations",
        denominator="population",
        group_by=["safeguard", "msoa"],
    ),

    Measure(
        id="dva_rate",
        numerator="consultations",
        denominator="population",
        group_by=["dva", "msoa"],
    ),
]
