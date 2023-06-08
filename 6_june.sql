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
        case
            when aba.Area is null then
                case
                    when asa.AREA is not null then concat('Store Area is ',asa.AREA)
                        else 'No Brand Area Assigned'
                end
            else aba.area
        end as Area_of_Brand,
        case
            when aba.Address is null then
                case
                    when asa.ADDRESS is not null then concat('Store Address is ',asa.ADDRESS)
                        else 'No brand Adress is there'
                end
            else aba.ADDRESS
        end as Address_of_brand,

        case
            when asa.area is null then
                case
                    when aba.area is not null then concat('Brand Area is ',aba.area)
                    else 'No Area Inputs available'
                end
            else asa.area
        end as Area_of_Store,


         case
            when asa.ADDRESS is null then
                case
                    when aba.ADDRESS is not null then concat('Brand address is ',aba.ADDRESS)
                    else 'No Adress Inputs available'
                end
             else asa.ADDRESS
        end as Address_of_Store,

        case
        when ats2.CAT_NAME is null then 'No value assigned'
            else ats2.CAT_NAME
        end as Ticket_sub_status,
        stt.type_name AS ticket_type,
        ati.call_title AS call_title,
        ati.created_by AS Created_user_id,
        case
         when concat(aei.First_name,' ',aei.Last_name) is null then 'Assigned engineer name not available'
         else concat(aei.First_name,' ',aei.Last_name)
        end as Name_of_Assigned_engineer,

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
    left join (select cat_name, Cat_ID from adm_ticket_status) as ats on ats.CAT_ID = ati.STATUS
    left join (select CAT_NAME, cat_id from adm_ticket_status) as ats2 on ats2.CAT_ID = ati.SUB_STATUS
    left join smr_ticket_type stt on stt.TEMP_ID = ati.TICKET_TYPE
        left join (select * from adm_ticket_followups where F_ID in (
                select max(F_ID) from adm_ticket_followups group by TICKET_ID)) atf on atf.TICKET_ID = ati.TEMP_ID
    left join (select * from adm_ticket_assigned where TEMP_ID in
                (select max(temp_id) from adm_ticket_assigned group by TICKET_ID)) ata on ati.TICKET_ID=ata.TICKET_ID
    left join adm_employee_info aei on ata.ASSIGNED_ENGG_ID=aei.ID
    left join adm_brand_address aba on abi.ADMIN_ID=aba.USER_ID
    left join adm_store_address asa on asa.ID= asi.ADMIN_ID
) a;