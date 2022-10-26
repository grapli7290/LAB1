--------------------------------------------------------------------------------------СОЗДАНИЕ ОТНОШЕНИЙ
create table Employees
(
	full_name_employee varchar(255) not null, --фио сотрудника
	job_title varchar(255) not null, --должность
	subdivision varchar(255) not null, --подразделение
	project_code_manage integer, --код проекта, которым руководит сотрудник
    primary key (full_name_employee)
);

create table Projects 
(
	project_code integer not null, --код проекта
	project_name varchar(255) not null, --название проекта
	task_name varchar(255) not null, --наименование задачи
	executor_name varchar(255) not null, --фио исполнителя
	hours integer, --трудоемкость в часах
	planned_date date not null, --плановая дата выполнения
	real_date date, --реальная дата
	done boolean DEFAULT false, --отметка о принятии
	task_description text, --описание задачи
	primary key (project_code, task_name),
	constraint alternative_key unique (project_name, task_name),
	foreign key (executor_name) references Employees (full_name_employee)
);



--------------------------------------------------------------------------------------ЗАПОЛНЕНИЕ ТЕСТОВЫМИ ДАННЫМИ
insert into employees values
('Орлова Екатерина Ивановна', 'Ассистент', 'Отдел HR', NULL),

('Гейнц Лилия Викторовна', 'Менеджер', 'Отдел HR', NULL),

('Федоров Александр Викторович', 'Тестировщик', 'Отдел тестирования', NULL),
('Петров Георгий Афанасьевич', 'Тестировщик', 'Отдел тестирования', NULL),
('Лебедева Мария Ильина', 'Тестировщик', 'Отдел тестирования', NULL),
('Минаев Михаил Богданович', 'Тестировщик', 'Отдел тестирования', NULL),
('Любимова Ольга Владимировна', 'Руководитель отдела тестирования', 'Отдел тестирования', '3'),

('Иванова Ульяна Леонидовна', 'Программист', 'Отдел разработки', NULL),
('Карпов Петр Дмитриевич', 'Программист', 'Отдел разработки', NULL),
('Карпова Анастасия Дмитриевна', 'Руководитель отдела разработки', 'Отдел разработки', '1'),

('Попов Алексей Александрович', 'Дизайнер', 'Отдел дизайна', '2');

insert into projects values
('1', 'Онлайн-игра', 'Разработать концепт 1', 'Попов Алексей Александрович', '40', '15-11-22', NULL, NULL, 'Task description'),
('1', 'Онлайн-игра', 'Реализовать модуль 1', 'Иванова Ульяна Леонидовна', '60', '29-11-22', NULL, NULL, 'Task description'),
('1', 'Онлайн-игра', 'Реализовать модуль 2', 'Иванова Ульяна Леонидовна', '80', '17-10-22', NULL, NULL, 'Task description'),
('1', 'Онлайн-игра', 'Реализовать модуль 3', 'Карпов Петр Дмитриевич', '100', '18-10-22', NULL, NULL, 'Task description'),
('1', 'Онлайн-игра', 'Протестировать', 'Минаев Михаил Богданович', '25', '15-09-22', '15-09-22', true, 'Task description'),
('1', 'Онлайн-игра', 'Руководить проектом', 'Карпова Анастасия Дмитриевна', '94', '01-01-23', NULL, NULL, 'Task description'),

('2', 'Корпоратив', 'Заказать еду', 'Лебедева Мария Ильина', '3', '29-12-22', '29-12-22', NULL, 'Task description'),
('2', 'Корпоратив', 'Организовать помещение', 'Федоров Александр Викторович', '3', '30-12-22', NULL, NULL, 'Task description'),
('2', 'Корпоратив', 'Руководить организацией', 'Попов Алексей Александрович', '3', '30-12-22', '31-12-22', true, 'Task description'),

('3', 'Веб-приложение', 'Верстка', 'Федоров Александр Викторович', '140', '03-02-24', NULL, NULL, 'Task description'),
('3', 'Веб-приложение', 'Верстка', 'Попов Алексей Александрович', '70', '15-02-24', NULL, NULL, 'Task description'),
('3', 'Веб-приложение', 'Тестирование, руководство', 'Любимова Ольга Владимировна', '94', '10-05-24', NULL, NULL, 'Task description'),
('3', 'Веб-приложение', 'Бэкенд', 'Иванова Ульяна Леонидовна', '80', '15-05-24', NULL, NULL, 'Task description'),
('3', 'Веб-приложение', 'Бэкенд', 'Карпова Анастасия Дмитриевна', '110', '20-12-23', NULL, NULL, 'Task description');



--------------------------------------------------------------------------------------ПОЛИТИКИ
--создание ролей
CREATE ROLE executor_group NOINHERIT;
CREATE ROLE teamlead_group NOINHERIT;

CREATE ROLE lyubimova;
CREATE ROLE popov;
CREATE ROLE orlova;
CREATE ROLE lebedeva;
CREATE ROLE petrov;

GRANT teamlead_group TO lyubimova;
GRANT teamlead_group TO  popov;

GRANT executor_group TO orlova;
GRANT executor_group TO lebedeva;
GRANT executor_group TO petrov;

--просмотр ролей
SELECT rolname FROM pg_roles;

--защита на уровне столбцов
GRANT SELECT (project_name, task_name, executor_name, hours, planned_date, real_date, task_description) 
    ON Projects 
    TO executor_group;

GRANT SELECT
    ON Projects
    TO teamlead_group;

GRANT SELECT 
    ON Employees
    TO executor_group;

 GRANT SELECT 
    ON Employees
    TO teamlead_group;  

GRANT UPDATE (planned_date)
    ON Projects 
    TO executor_group;

GRANT UPDATE (done)
    ON Projects 
    TO teamlead_group;

--защита на уровне строк
alter table projects enable row level security;

CREATE POLICY policy_select_for_executor_group ON Projects
    FOR SELECT
    TO executor_group
    USING (executor_name IN (SELECT full_name_employee FROM Employees WHERE login = CURRENT_ROLE));
    
CREATE POLICY policy_update_for_executor_group ON Projects
    FOR UPDATE
    TO executor_group
    USING (executor_name IN (SELECT full_name_employee FROM Employees WHERE login = CURRENT_ROLE));



CREATE POLICY policy_select_for_teamlead_group ON Projects
    FOR SELECT
    TO teamlead_group
    USING (executor_name IN (SELECT full_name_employee FROM Employees WHERE login = CURRENT_ROLE));
    
CREATE POLICY policy_update_for_teamlead_group ON Projects
    FOR UPDATE
    TO teamlead_group
    USING (executor_name IN (SELECT full_name_employee FROM Employees WHERE login = CURRENT_ROLE));

--исправляем беду :с
ALTER TABLE Employees ADD COLUMN login varchar(255) not null DEFAULT 'xxx';

DROP POLICY policy_select_for_executor ON Projects;
DROP POLICY policy_update_for_executor_group ON Projects;
DROP POLICY policy_select_for_teamlead_group ON Projects;
DROP POLICY policy_update_for_teamlead_group ON Projects;

UPDATE Employees 
    SET login = 'orlova' 
    WHERE full_name_employee = 'Орлова Екатерина Ивановна';

UPDATE Employees 
    SET login = 'lyubimova' 
    WHERE full_name_employee = 'Любимова Ольга Владимировна';

UPDATE Employees 
    SET login = 'popov' 
    WHERE full_name_employee = 'Попов Алексей Александрович';

UPDATE Employees 
    SET login = 'lebedeva' 
    WHERE full_name_employee = 'Лебедева Мария Ильина';

UPDATE Employees 
    SET login = 'petrov' 
    WHERE full_name_employee = 'Петров Георгий Афанасьевич';