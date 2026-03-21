select max(x), min(x) from Accelerations
select max(y), min(y) from Accelerations
select max(z), min(z) from Accelerations
select (max(x) - min(x)) / 9.81 from Accelerations
select (max(y) - min(y)) / 9.81 from Accelerations
select (max(z) - min(z)) / 9.81 from Accelerations
