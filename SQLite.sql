-- Create raw tables
CREATE TABLE raw_users (
 user_id INT,
 user_name VARCHAR(100),
 country VARCHAR(50)
);

CREATE TABLE raw_posts (
  post_id INT,
  post_text VARCHAR(500),
  post_date DATE,
  user_id INT
);

CREATE TABLE raw_likes (
  like_id INT,
  user_id INT,
  post_id INT,
  like_date DATE
);

-- Insert sample data
INSERT INTO raw_users
VALUES
(1, 'john_doe', 'Canada'),
(2, 'jane_smith', 'USA'),
(3, 'bob_johnson', 'UK');

INSERT INTO raw_posts
VALUES
(101, 'My first post!', '2020-01-01', 1),
(102, 'Having fun learning SQL', '2020-01-02', 2),
(103, 'Big data is cool', '2020-01-03', 1),
(104, 'Just joined this platform', '2020-01-04', 3),
(105, 'Whats everyone up to today?', '2020-01-05', 2),
(106, 'Data science is the future', '2020-01-06', 1),
(107, 'Practicing my SQL skills', '2020-01-07', 2),
(108, 'Hows the weather where you are?', '2020-01-08', 3),
(109, 'TGI Friday!', '2020-01-09', 1),
(110, 'Any big plans for the weekend?', '2020-01-10', 2);

INSERT INTO raw_likes
VALUES
(1001, 1, 101, '2020-01-01'),
(1002, 3, 101, '2020-01-02'),
(1003, 2, 102, '2020-01-03'),
(1004, 1, 103, '2020-01-04'),
(1005, 3, 104, '2020-01-05'),
(1006, 2, 104, '2020-01-06'),
(1007, 1, 105, '2020-01-07'),
(1008, 2, 106, '2020-01-08'),
(1009, 3, 107, '2020-01-09'),
(1010, 1, 108, '2020-01-10'),
(1011, 2, 109, '2020-01-11'),
(1012, 3, 110, '2020-01-12');

CREATE TABLE dim_user (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100),
    country VARCHAR(50)
);

-- Populate dim_user
INSERT INTO dim_user (user_id, user_name, country)
SELECT DISTINCT user_id, user_name, country FROM raw_users;

CREATE TABLE dim_post (
    post_id INT PRIMARY KEY,
    post_text VARCHAR(500),
    post_date DATE,
    user_id INT,
    FOREIGN KEY (user_id) REFERENCES dim_user(user_id)
);

-- Populate dim_post
INSERT INTO dim_post (post_id, post_text, post_date, user_id)
SELECT DISTINCT post_id, post_text, post_date, user_id FROM raw_posts;

CREATE TABLE dim_date (
    post_date DATE PRIMARY KEY
);

-- Populate dim_date
INSERT INTO dim_date (post_date)
SELECT DISTINCT post_date FROM raw_posts;

CREATE TABLE fact_post_performance (
    post_date DATE,
    post_id INT,
    views INT,
    likes INT,
    PRIMARY KEY (post_date, post_id),
    FOREIGN KEY (post_date) REFERENCES dim_date(post_date),
    FOREIGN KEY (post_id) REFERENCES dim_post(post_id)
);

-- Populate fact_post_performance
INSERT INTO fact_post_performance (post_date, post_id, views, likes)
SELECT
    rp.post_date,
    rp.post_id,
    COUNT(DISTINCT rl.user_id) AS views,
    COUNT(rl.like_id) AS likes
FROM raw_posts rp
LEFT JOIN raw_likes rl ON rp.post_id = rl.post_id
GROUP BY rp.post_date, rp.post_id;

CREATE TABLE fact_daily_posts (
    post_date DATE,
    user_id INT,
    num_posts INT,
    PRIMARY KEY (post_date, user_id),
    FOREIGN KEY (post_date) REFERENCES dim_date(post_date),
    FOREIGN KEY (user_id) REFERENCES dim_user(user_id)
);

-- Populate fact_daily_posts
INSERT INTO fact_daily_posts (post_date, user_id, num_posts)
SELECT
    rp.post_date,
    rp.user_id,
    COUNT(rp.post_id) AS num_posts
FROM raw_posts rp
GROUP BY rp.post_date, rp.user_id;