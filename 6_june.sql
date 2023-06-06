SELECT a.*
FROM (
    SELECT
        ati.ticket_id AS ticket_id,
        ati.TEMP_ID AS unique_t_id,
        ati.STORE_ID AS ticket_store_id,
        abi.company_name AS brand,
        aci.company_name AS client,
        asi.company_name AS store_name,
        asr.store_id AS store_id,
        ats.cat_name AS ticket_status,
        stt.type_name AS ticket_type,
        ati.call_title AS call_title,
        ati.created_by AS Created_user_id,
        case
            when ata.assigned_engg_id is null then 'no assigned engineer inputted'
                else ata.assigned_engg_id
        end as assigned_engg_id,

        case
            when ata.assigned_type is null then 'no assigned type inputted'
                else ata.assigned_type
        end as assigned_type,

        case
            when ati.region is null then 'No region inputted'
            else ati.region
        end as zone,

        case
        when ati.cust_ticket_number is not null then ati.cust_ticket_number
        else 'No value'
        end as cust_ticket,

        case
        when atf.DATE is null then 'No followups'
        else atf.DATE
    end AS last_follow_up_date,

        CASE
            WHEN atf.DETAILS IS NOT NULL THEN atf.DETAILS
            ELSE 'No followup message'
        END AS last_follow_up_message,

        TIMESTAMPDIFF(MONTH, ati.ENTRYTIME, DATE_ADD(NOW(), INTERVAL 330 MINUTE)) AS ticket_age,
        TIMESTAMPDIFF(MONTH, atf.DATE, DATE_ADD(NOW(), INTERVAL 330 MINUTE)) AS followup_age,

        CASE
            WHEN TIMESTAMPDIFF(MONTH, ati.ENTRYTIME, DATE_ADD(NOW(), INTERVAL 330 MINUTE)) BETWEEN 0 AND 3 THEN '0-3'
            when timestampdiff(month , ati.ENTRYTIME, date_add(now(), interval 330 minute)) between 4 and 7 then '4-7'
        when timestampdiff(month , ati.ENTRYTIME, date_add(now(), interval 330 minute)) >7 then '7+'
            else 'No information'
            end as ticket_age_group
from adm_ticket_info ati
    left join adm_store_regdetails asr on ati.TEMP_ID = asr.ID
    left join adm_store_info asi on asi.ADMIN_ID = asr.ID
    left join adm_brand_regdetails abr on abr.ID = asr.BRAND_ID
    left join adm_brand_info abi on abr.ID = abi.ADMIN_ID
    left join adm_client_regdetails acr on acr.ID = abr.COMPANY_ID
    left join adm_client_info aci on aci.ADMIN_ID = acr.ID
    left join adm_ticket_status ats on ats.CAT_ID = ati.SUB_STATUS
    left join smr_ticket_type stt on stt.TEMP_ID = ati.TICKET_TYPE
        left join (select * from adm_ticket_followups where F_ID in (
                select max(F_ID) from adm_ticket_followups group by TICKET_ID)) atf on atf.TICKET_ID = ati.TEMP_ID
    left join (select * from adm_ticket_assigned where TEMP_ID in
                (select max(temp_id) from adm_ticket_assigned group by TICKET_ID)) ata on ati.TICKET_ID=ata.TICKET_ID
) a;