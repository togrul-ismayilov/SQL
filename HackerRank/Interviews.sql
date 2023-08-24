select cnt.contest_id,cnt.hacker_id, cnt.name, 
sum(ss.tot_sub),
sum(ss.tot_ac_sub),
sum(tot_v),
sum(tot_un_v)
from contests cnt
inner join colleges clg on cnt.contest_id=clg.contest_id
inner join challenges chl on chl.college_id=clg.college_id
left join (select challenge_id,
                sum(total_views) tot_v,
                sum(total_unique_views) tot_un_v from view_stats
                group by challenge_id) vs 
        on chl.challenge_id=vs.challenge_id
left join (select  challenge_id,
                    sum(total_submissions) tot_sub,
                    sum(total_accepted_submissions) tot_ac_sub from Submission_Stats
                    group by challenge_id) ss 
        on ss.challenge_id=chl.challenge_id
group by cnt.contest_id,cnt.hacker_id, cnt.name
having (nvl(sum(ss.tot_sub),0)+ nvl(sum(ss.tot_ac_sub),0)+nvl(sum(tot_v),0)+nvl(sum(tot_un_v),0))<>0
order by contest_id;