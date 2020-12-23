# Subject area "railway"
## Entity Relationship diagram №1.2 #
![](http://www.plantuml.com/plantuml/proxy?cache=yes&src=https://raw.githubusercontent.com/vano7577/DB2/master/ER_1_2.puml)
## Datalogical model
![.](https://github.com/vano7577/DB2/blob/main/datalogical_model.png)
integrity constraints:

abbreviation  | integrity constraints
------------- | -------------
PK | primary key
FK | foreign key
UN | unique
NN | NOT NULL
CH | CHECK
CH1 | ~ '^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$'
CH2 | ~ '^\D+$'
CH3 | > '1900-01-01'
CH4 | >=0
CH5 | BETWEEN 0 AND 100
CH6 | >0
CH7 | >=1825

## Physical data model
![.](https://github.com/vano7577/DB2/blob/main/Physical_data_model_railway.png)
