/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT * 
FROM  `Facilities` 
WHERE membercost > 0

/*ANSWER 1:
  Massage Room 1, Massage Room 2, Tennis Court 1, Tennis Cout 2, Squash Court */
  
/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(membercost)
FROM  `Facilities`
WHERE membercost = 0

/* ANSWER 2: 4 facilities do not charge member fees. */

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM  `Facilities` 
WHERE membercost < ( monthlymaintenance * .2 ) 

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM `Facilities`
WHERE facid IN (1,5)


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
    CASE WHEN monthlymaintenance > 100 THEN 'expensive'
         ELSE 'cheap' END AS cheap_or_expensive 
FROM `Facilities`         


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM `Members`
WHERE joindate = 
    (
        SELECT MAX(joindate)
        FROM `Members`
    )
    
/* ANSWER 6:
   firstname surname
   Darren    Smith    */
   
/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT(mems.firstname, ' ', mems.surname) AS full_name, 
       fac.name as facility
FROM `Bookings` book 
JOIN `Members` mems ON book.memid = mems.memid
JOIN `Facilities` fac ON book.facid = fac.facid
WHERE fac.name LIKE 'TENNIS%' AND mems.firstname != 'Guest'
ORDER BY full_name, facility

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT fac.name AS facility, 
       CONCAT(mems.firstname, ' ', mems.surname) AS full_name,
       CASE WHEN book.memid = 0 THEN fac.guestcost * book.slots
            ELSE fac.membercost * book.slots END AS cost 
FROM `Bookings` book 
JOIN `Members` mems ON book.memid = mems.memid
JOIN `Facilities` fac ON book.facid = fac.facid
WHERE book.starttime LIKE '2012-09-14%'
HAVING cost > 30
ORDER BY cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT fac.name AS facility, 
       CONCAT(mems.firstname, ' ', mems.surname) AS full_name,
       CASE WHEN book.memid = 0 THEN fac.guestcost * book.slots
            ELSE fac.membercost * book.slots END AS cost 
FROM (SELECT *
      FROM `Bookings` 
      WHERE starttime LIKE '2012-09-14%') book
JOIN `Members` mems ON book.memid = mems.memid
JOIN `Facilities` fac ON book.facid = fac.facid
HAVING cost > 30
ORDER BY cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */


SELECT sub.name AS facility,         --selects columns with facility name and total revenue
       SUM(sub.revenue) AS total_rev --    (members and guests) for that facility
FROM (SELECT fac.name,
             CASE WHEN book.mem_or_guest = 'member' THEN book.total_slots * membercost
                  ELSE book.total_slots * guestcost END AS revenue
      FROM (SELECT facid, 
                   CASE WHEN memid =0 THEN  'guest'
                        ELSE  'member' END AS mem_or_guest, --subquery 'book' gets total slots booked per facilty 
                   SUM( slots ) AS total_slots              -- for members and guests, respectively
            FROM `Bookings`
            GROUP BY facid, mem_or_guest) book
      JOIN `Facilities` fac ON book.facid = fac.facid) sub  --subquery 'sub' calculates revenue generated by members
GROUP BY facility                                         --   and revenue generated by guests for each facility
HAVING total_rev < 1000
ORDER BY total_rev

/* ANSWER 10: 
   facility       total_rev
   Table Tennis   180.0
   Snooker Table  240.0
   Pool Table     270.0        */
