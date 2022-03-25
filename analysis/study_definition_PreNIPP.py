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
        }
    ),

    #Define Vulnerable groups using a loockback period prior to index date:
    
    # 1. patients with intellectual disability - codelist from OpenCodelists.org
    IntDis=patients.with_these_clinical_events(
        IntDis_codes,
        #between=["2019-09-01", "2019-03-01"], #fixed cohort definition
        between=["index_date", "index_date - 183 days"], #dynamic cohort definition with moving window
        returning="binary_flag",
        return_expectations={
        "incidence": 0.05,
        },
    ),

    # 2. children with safeguarding concerns - codelist from study team based on RCGP guidance
    #    To be combined with an age cutoff: <18 years
    RCGP_safeguard=patients.with_these_clinical_events(
        RCGPsafeguard_codes,
        #between=["2019-09-01", "2019-03-01"], #fixed cohort definition
        between=["index_date", "index_date - 183 days"], #dynamic cohort definition with moving window
        returning="binary_flag",
        return_expectations={
        "incidence": 0.05,
        },
    ),

    # 3. Several other vulnerable groups defined by different codelists to be added here ...

    #count of GP-patient interactions for all patients (vulnerable or not) - main study outcome
    consultations=patients.with_gp_consultations(
        between=["index_date", "index_date + 6 days"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "poisson", "mean": 1},
            "incidence": 1.0,
        },
    ),
)
