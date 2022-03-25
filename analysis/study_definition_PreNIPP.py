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

    sex=patients.sex(
    return_expectations={
        "rate": "universal",
        "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),

    #Define Vulnerable groups using a loockback period prior to index date:
    
    # 1. patients with intellectual disability
    IntDis=patients.with_these_clinical_events(
        IntDis_codes,
        #between=["2019-09-01", "2019-03-01"], #fixed cohort definition
        between=["index_date", "index_date - 183 days"], #dynamic cohort definition with moving window
        returning="binary_flag",
        return_expectations={
        "incidence": 0.05,
        },
    ),

    # children with safeguarding concerns
    RCGP_safeguard=patients.with_these_clinical_events(
        RCGPsafeguard_codes,
        #between=["2019-09-01", "2019-03-01"], #fixed cohort definition
        between=["index_date", "index_date - 183 days"], #dynamic cohort definition with moving window
        returning="binary_flag",
        return_expectations={
        "incidence": 0.05,
        },
    ),

    # 3. Other vulnerable groups defined by different codelists to be added here ...

    #count of GP-patient interactions - main study outcome
    consultations=patients.with_gp_consultations(
        between=["index_date", "index_date + 6 days"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "poisson", "mean": 1},
            "incidence": 1.0,
        },
    ),
)
